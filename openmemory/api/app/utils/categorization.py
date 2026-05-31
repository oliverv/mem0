import logging
import os
from typing import List

from app.utils.prompts import MEMORY_CATEGORIZATION_PROMPT
from dotenv import load_dotenv
from pydantic import BaseModel
from tenacity import retry, stop_after_attempt, wait_exponential

load_dotenv()

logger = logging.getLogger(__name__)


class MemoryCategories(BaseModel):
    categories: List[str]


def _get_openai_client():
    """
    Lazily build an OpenAI-compatible client from the active LLM config in the DB.
    Falls back to a plain OpenAI client using OPENAI_API_KEY if anything goes wrong.
    Providers supported for structured-output categorization:
      openai, xai, deepseek, groq, together, mistralai (all expose an OpenAI-compat API).
    For providers that don't (anthropic, gemini, ollama, etc.) we fall back to OpenAI.
    """
    # Providers that speak the OpenAI chat-completions wire protocol
    OPENAI_COMPAT_PROVIDERS = {"openai", "xai", "deepseek", "groq", "together", "mistralai", "litellm"}

    try:
        from openai import OpenAI
        from app.database import SessionLocal
        from app.models import Config as ConfigModel

        db = SessionLocal()
        try:
            db_config = db.query(ConfigModel).filter(ConfigModel.key == "main").first()
        finally:
            db.close()

        if db_config and "mem0" in db_config.value:
            llm_cfg = db_config.value["mem0"].get("llm", {})
            provider = (llm_cfg.get("provider") or "openai").lower()
            cfg = llm_cfg.get("config", {})

            # Resolve env: references
            def _resolve(val):
                if isinstance(val, str) and val.startswith("env:"):
                    return os.environ.get(val[4:], "")
                return val

            api_key = _resolve(cfg.get("api_key"))
            base_url = None

            if provider in OPENAI_COMPAT_PROVIDERS:
                if provider == "xai":
                    base_url = cfg.get("xai_base_url") or os.environ.get("XAI_API_BASE") or "https://api.x.ai/v1"
                    api_key = api_key or os.environ.get("XAI_API_KEY")
                elif provider == "deepseek":
                    base_url = cfg.get("deepseek_base_url") or "https://api.deepseek.com"
                elif provider == "groq":
                    base_url = "https://api.groq.com/openai/v1"
                elif provider == "together":
                    base_url = "https://api.together.xyz/v1"

                if api_key:
                    return OpenAI(api_key=api_key, base_url=base_url), provider
    except Exception as e:
        logger.debug(f"[categorization] Could not load LLM config from DB: {e}")

    # Fallback: plain OpenAI
    from openai import OpenAI
    return OpenAI(), "openai"


def _get_model_for_provider(provider: str, cfg: dict) -> str:
    """Pick an appropriate model name for structured-output categorization."""
    model = cfg.get("model", "")
    if model:
        return model
    defaults = {
        "xai": "grok-2-latest",
        "deepseek": "deepseek-chat",
        "groq": "llama3-8b-8192",
        "together": "mistralai/Mixtral-8x7B-Instruct-v0.1",
        "openai": "gpt-4o-mini",
    }
    return defaults.get(provider, "gpt-4o-mini")


@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=15))
def get_categories_for_memory(memory: str) -> List[str]:
    try:
        client, provider = _get_openai_client()

        # Resolve model from DB config where possible
        model = "gpt-4o-mini"
        try:
            from app.database import SessionLocal
            from app.models import Config as ConfigModel
            db = SessionLocal()
            try:
                db_config = db.query(ConfigModel).filter(ConfigModel.key == "main").first()
            finally:
                db.close()
            if db_config and "mem0" in db_config.value:
                llm_cfg = db_config.value["mem0"].get("llm", {})
                model = _get_model_for_provider(provider, llm_cfg.get("config", {}))
        except Exception:
            pass

        messages = [
            {"role": "system", "content": MEMORY_CATEGORIZATION_PROMPT},
            {"role": "user", "content": memory},
        ]

        completion = client.beta.chat.completions.parse(
            model=model,
            messages=messages,
            response_format=MemoryCategories,
            temperature=0,
        )

        parsed: MemoryCategories = completion.choices[0].message.parsed
        return [cat.strip().lower() for cat in parsed.categories]

    except Exception as e:
        logger.error(f"[categorization] Failed to get categories: {e}")
        try:
            # noinspection PyUnboundLocalVariable
            logger.debug(f"[categorization] Raw response: {completion.choices[0].message.content}")
        except Exception:
            pass
        raise
