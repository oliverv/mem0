"""
Memory categorization using the configured LLM (provider-agnostic).

Instead of calling OpenAI directly, we call get_memory_client() which already
holds the user-configured LLM (xAI, Gemini, LiteLLM, Ollama, Vertex AI, etc.)
and ask it to return JSON via a plain chat prompt.  This means categorization
works with every provider mem0 supports.
"""
import json
import logging
from typing import List

from app.utils.prompts import MEMORY_CATEGORIZATION_PROMPT
from dotenv import load_dotenv
from tenacity import retry, stop_after_attempt, wait_exponential

load_dotenv()
logger = logging.getLogger(__name__)

_CATEGORIZE_SYSTEM = (
    MEMORY_CATEGORIZATION_PROMPT.strip()
    + "\n\nReturn ONLY valid JSON in the exact format: "
    + '{"categories": ["cat1", "cat2"]}'
    + "\nNo markdown, no explanation, just the JSON object."
)


def _parse_categories(raw: str) -> List[str]:
    """Extract categories list from a raw LLM response string."""
    raw = raw.strip()
    # Strip markdown code fences if present
    if raw.startswith("```"):
        lines = raw.splitlines()
        raw = "\n".join(lines[1:-1] if lines[-1].strip() == "```" else lines[1:])
    try:
        data = json.loads(raw)
        cats = data.get("categories", [])
        return [c.strip().lower() for c in cats if isinstance(c, str)]
    except json.JSONDecodeError:
        # Last-ditch: try to find a JSON object anywhere in the string
        import re
        m = re.search(r'\{.*?"categories"\s*:\s*\[.*?\]\s*\}', raw, re.DOTALL)
        if m:
            try:
                data = json.loads(m.group(0))
                cats = data.get("categories", [])
                return [c.strip().lower() for c in cats if isinstance(c, str)]
            except json.JSONDecodeError:
                pass
        logger.warning("[categorization] Could not parse JSON from LLM response: %s", raw[:200])
        return []


@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=15))
def get_categories_for_memory(memory: str) -> List[str]:
    """
    Categorize a memory string using the currently configured LLM.
    Works with any provider (xAI, Gemini, LiteLLM, Vertex AI, Ollama, OpenAI, etc.)
    """
    try:
        from app.utils.memory import get_memory_client
        client = get_memory_client()

        if client is None:
            logger.warning("[categorization] Memory client unavailable, skipping categorization")
            return []

        llm = client.llm  # the underlying LLMBase instance

        messages = [
            {"role": "system", "content": _CATEGORIZE_SYSTEM},
            {"role": "user", "content": memory},
        ]

        raw = llm.generate_response(messages)
        return _parse_categories(raw)

    except Exception as e:
        logger.error("[categorization] Failed to get categories: %s", e)
        raise
