#!/bin/bash

set -e

echo "🚀 Starting OpenMemory installation..."

# =============================================================================
# Identity
# =============================================================================
USER="${USER:-$(whoami)}"
NEXT_PUBLIC_API_URL="${NEXT_PUBLIC_API_URL:-http://localhost:8765}"

# =============================================================================
# LLM provider detection
# Supported: openai | xai | google | anthropic | litellm | groq | ollama
#            deepseek | together | aws_bedrock | azure_openai | mistralai
#            lmstudio | vllm
# =============================================================================
LLM_PROVIDER="${LLM_PROVIDER:-}"
LLM_MODEL="${LLM_MODEL:-}"
LLM_API_KEY="${LLM_API_KEY:-}"
LLM_BASE_URL="${LLM_BASE_URL:-}"

# Provider-specific key aliases → normalise into LLM_API_KEY if not already set
OPENAI_API_KEY="${OPENAI_API_KEY:-}"
XAI_API_KEY="${XAI_API_KEY:-}"
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
GROQ_API_KEY="${GROQ_API_KEY:-}"
TOGETHER_API_KEY="${TOGETHER_API_KEY:-}"
DEEPSEEK_API_KEY="${DEEPSEEK_API_KEY:-}"
MISTRAL_API_KEY="${MISTRAL_API_KEY:-}"
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
AWS_REGION_NAME="${AWS_REGION_NAME:-us-east-1}"
OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://host.docker.internal:11434}"

# Auto-detect provider from whichever key is set (if LLM_PROVIDER not explicit)
if [ -z "$LLM_PROVIDER" ]; then
  if   [ -n "$OPENAI_API_KEY" ];    then LLM_PROVIDER="openai"
  elif [ -n "$XAI_API_KEY" ];       then LLM_PROVIDER="xai"
  elif [ -n "$GEMINI_API_KEY" ];    then LLM_PROVIDER="google"
  elif [ -n "$ANTHROPIC_API_KEY" ]; then LLM_PROVIDER="anthropic"
  elif [ -n "$GROQ_API_KEY" ];      then LLM_PROVIDER="groq"
  elif [ -n "$TOGETHER_API_KEY" ];  then LLM_PROVIDER="together"
  elif [ -n "$DEEPSEEK_API_KEY" ];  then LLM_PROVIDER="deepseek"
  elif [ -n "$MISTRAL_API_KEY" ];   then LLM_PROVIDER="mistralai"
  elif [ -n "$AWS_ACCESS_KEY_ID" ]; then LLM_PROVIDER="aws_bedrock"
  else
    echo "❌ No LLM provider configured."
    echo "   Set LLM_PROVIDER + LLM_API_KEY, or one of:"
    echo "   OPENAI_API_KEY | XAI_API_KEY | GEMINI_API_KEY | ANTHROPIC_API_KEY"
    echo "   GROQ_API_KEY | TOGETHER_API_KEY | DEEPSEEK_API_KEY | MISTRAL_API_KEY"
    echo "   AWS_ACCESS_KEY_ID+AWS_SECRET_ACCESS_KEY | LLM_PROVIDER=ollama"
    exit 1
  fi
fi

# Fill LLM_API_KEY from provider-specific alias if not set
if [ -z "$LLM_API_KEY" ]; then
  case "$LLM_PROVIDER" in
    openai)    LLM_API_KEY="$OPENAI_API_KEY" ;;
    xai)       LLM_API_KEY="$XAI_API_KEY" ;;
    google)    LLM_API_KEY="$GEMINI_API_KEY" ;;
    anthropic) LLM_API_KEY="$ANTHROPIC_API_KEY" ;;
    groq)      LLM_API_KEY="$GROQ_API_KEY" ;;
    together)  LLM_API_KEY="$TOGETHER_API_KEY" ;;
    deepseek)  LLM_API_KEY="$DEEPSEEK_API_KEY" ;;
    mistralai) LLM_API_KEY="$MISTRAL_API_KEY" ;;
  esac
fi

# Default models per provider
if [ -z "$LLM_MODEL" ]; then
  case "$LLM_PROVIDER" in
    openai)     LLM_MODEL="gpt-4o-mini" ;;
    xai)        LLM_MODEL="grok-2-latest" ;;
    google)     LLM_MODEL="gemini-2.0-flash" ;;
    anthropic)  LLM_MODEL="claude-3-5-haiku-20241022" ;;
    groq)       LLM_MODEL="llama-3.3-70b-versatile" ;;
    together)   LLM_MODEL="mistralai/Mixtral-8x7B-Instruct-v0.1" ;;
    deepseek)   LLM_MODEL="deepseek-chat" ;;
    mistralai)  LLM_MODEL="mistral-large-latest" ;;
    ollama)     LLM_MODEL="llama3.1:latest" ;;
    aws_bedrock) LLM_MODEL="anthropic.claude-3-5-haiku-20241022-v1:0" ;;
    lmstudio)   LLM_MODEL="local-model" ;;
    vllm)       LLM_MODEL="local-model" ;;
    litellm)    LLM_MODEL="gpt-4o-mini" ;;
    *)          LLM_MODEL="gpt-4o-mini" ;;
  esac
fi

echo "🤖 LLM: $LLM_PROVIDER / $LLM_MODEL"

# =============================================================================
# Embedder provider detection
# Supported: openai | google | vertexai | ollama | huggingface | fastembed
#            azure_openai | together | aws_bedrock | lmstudio
# =============================================================================
EMBEDDER_PROVIDER="${EMBEDDER_PROVIDER:-}"
EMBEDDER_MODEL="${EMBEDDER_MODEL:-}"
EMBEDDER_API_KEY="${EMBEDDER_API_KEY:-}"
EMBEDDER_BASE_URL="${EMBEDDER_BASE_URL:-}"

# Default embedder = same provider as LLM where supported, else openai
if [ -z "$EMBEDDER_PROVIDER" ]; then
  case "$LLM_PROVIDER" in
    openai|google|ollama|azure_openai|together|aws_bedrock|lmstudio) EMBEDDER_PROVIDER="$LLM_PROVIDER" ;;
    *) EMBEDDER_PROVIDER="openai" ;;
  esac
fi

if [ -z "$EMBEDDER_API_KEY" ]; then
  EMBEDDER_API_KEY="$LLM_API_KEY"
fi

if [ -z "$EMBEDDER_MODEL" ]; then
  case "$EMBEDDER_PROVIDER" in
    openai)     EMBEDDER_MODEL="text-embedding-3-small" ;;
    google)     EMBEDDER_MODEL="models/text-embedding-004" ;;
    vertexai)   EMBEDDER_MODEL="text-embedding-004" ;;
    ollama)     EMBEDDER_MODEL="nomic-embed-text" ;;
    huggingface) EMBEDDER_MODEL="sentence-transformers/all-MiniLM-L6-v2" ;;
    fastembed)  EMBEDDER_MODEL="BAAI/bge-small-en-v1.5" ;;
    together)   EMBEDDER_MODEL="togethercomputer/m2-bert-80M-8k-retrieval" ;;
    aws_bedrock) EMBEDDER_MODEL="amazon.titan-embed-text-v2:0" ;;
    lmstudio)   EMBEDDER_MODEL="local-embedding-model" ;;
    azure_openai) EMBEDDER_MODEL="text-embedding-ada-002" ;;
    *)          EMBEDDER_MODEL="text-embedding-3-small" ;;
  esac
fi

echo "🔢 Embedder: $EMBEDDER_PROVIDER / $EMBEDDER_MODEL"

# =============================================================================
# Docker checks
# =============================================================================
if ! command -v docker &> /dev/null; then
  echo "❌ Docker not found. Please install Docker first."
  exit 1
fi

if ! docker compose version &> /dev/null; then
  echo "❌ Docker Compose V2 not found. Please install it first."
  exit 1
fi

# Remove stale UI container if present
if [ $(docker ps -aq -f name=mem0_ui) ]; then
  echo "⚠️  Removing stale mem0_ui container..."
  docker rm -f mem0_ui
fi

# Find available frontend port
echo "🔍 Looking for available frontend port..."
for port in {3000..3010}; do
  if ! lsof -i:$port >/dev/null 2>&1; then
    FRONTEND_PORT=$port
    break
  fi
done
if [ -z "$FRONTEND_PORT" ]; then
  echo "❌ No available port between 3000-3010."
  exit 1
fi

# =============================================================================
# Vector store selection
# =============================================================================
VECTOR_STORE="${VECTOR_STORE:-qdrant}"
EMBEDDING_DIMS="${EMBEDDING_DIMS:-1536}"

for arg in "$@"; do
  case $arg in
    --vector-store=*) VECTOR_STORE="${arg#*=}"; shift ;;
    --vector-store)   VECTOR_STORE="$2"; shift 2 ;;
    *) ;;
  esac
done

echo "🧰 Vector store: $VECTOR_STORE"

# =============================================================================
# Build docker-compose.yml
# =============================================================================
create_compose_file() {
  local vector_store=$1
  local compose_file="compose/${vector_store}.yml"
  local volume_name="${vector_store}_data"

  if [ ! -f "$compose_file" ]; then
    echo "❌ Compose file not found: $compose_file"
    echo "   Available: $(ls compose/*.yml | sed 's/compose\///;s/\.yml//' | tr '\n' ' ')"
    exit 1
  fi

  echo "📝 Building docker-compose.yml from $compose_file..."

  echo "services:" > docker-compose.yml
  tail -n +2 "$compose_file" | sed '/^volumes:/,$d' | sed "s/mem0_storage/${volume_name}/g" >> docker-compose.yml
  echo "" >> docker-compose.yml

  cat >> docker-compose.yml <<EOF
  openmemory-mcp:
    image: mem0/openmemory-mcp:latest
    environment:
      - USER=${USER}
      - LLM_PROVIDER=${LLM_PROVIDER}
      - LLM_MODEL=${LLM_MODEL}
      - LLM_API_KEY=${LLM_API_KEY}
      - LLM_BASE_URL=${LLM_BASE_URL}
      - EMBEDDER_PROVIDER=${EMBEDDER_PROVIDER}
      - EMBEDDER_MODEL=${EMBEDDER_MODEL}
      - EMBEDDER_API_KEY=${EMBEDDER_API_KEY}
      - EMBEDDER_BASE_URL=${EMBEDDER_BASE_URL}
      - OLLAMA_BASE_URL=${OLLAMA_BASE_URL}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - XAI_API_KEY=${XAI_API_KEY}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - GROQ_API_KEY=${GROQ_API_KEY}
      - TOGETHER_API_KEY=${TOGETHER_API_KEY}
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
      - MISTRAL_API_KEY=${MISTRAL_API_KEY}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION_NAME=${AWS_REGION_NAME}
EOF

  # Vector store env vars
  case "$vector_store" in
    qdrant)        echo "      - QDRANT_HOST=mem0_store"$'\n'"      - QDRANT_PORT=6333" >> docker-compose.yml ;;
    chroma)        echo "      - CHROMA_HOST=mem0_store"$'\n'"      - CHROMA_PORT=8000" >> docker-compose.yml ;;
    weaviate)      echo "      - WEAVIATE_HOST=mem0_store"$'\n'"      - WEAVIATE_PORT=8080" >> docker-compose.yml ;;
    redis)         echo "      - REDIS_URL=redis://mem0_store:6379" >> docker-compose.yml ;;
    pgvector)      printf "      - PG_HOST=mem0_store\n      - PG_PORT=5432\n      - PG_DB=mem0\n      - PG_USER=mem0\n      - PG_PASSWORD=mem0\n" >> docker-compose.yml ;;
    milvus)        echo "      - MILVUS_HOST=mem0_store"$'\n'"      - MILVUS_PORT=19530" >> docker-compose.yml ;;
    elasticsearch) printf "      - ELASTICSEARCH_HOST=mem0_store\n      - ELASTICSEARCH_PORT=9200\n      - ELASTICSEARCH_USER=elastic\n      - ELASTICSEARCH_PASSWORD=changeme\n" >> docker-compose.yml ;;
    opensearch)    echo "      - OPENSEARCH_HOST=mem0_store"$'\n'"      - OPENSEARCH_PORT=9200" >> docker-compose.yml ;;
    faiss)         echo "      - FAISS_PATH=/tmp/faiss" >> docker-compose.yml ;;
    *)
      echo "⚠️  Unknown vector store '$vector_store', defaulting to qdrant."
      echo "      - QDRANT_HOST=mem0_store"$'\n'"      - QDRANT_PORT=6333" >> docker-compose.yml
      ;;
  esac

  if [ "$vector_store" = "faiss" ]; then
    cat >> docker-compose.yml <<EOF
    ports:
      - "8765:8765"
    volumes:
      - openmemory_db:/usr/src/openmemory
      - ${volume_name}:/tmp/faiss

volumes:
  ${volume_name}:
  openmemory_db:
EOF
  else
    cat >> docker-compose.yml <<EOF
    depends_on:
      - mem0_store
    ports:
      - "8765:8765"
    volumes:
      - openmemory_db:/usr/src/openmemory

volumes:
  ${volume_name}:
  openmemory_db:
EOF
  fi
}

create_compose_file "$VECTOR_STORE"

# Milvus needs local dirs
if [ "$VECTOR_STORE" = "milvus" ]; then
  mkdir -p ./data/milvus/etcd ./data/milvus/minio ./data/milvus/milvus
fi

# =============================================================================
# Start services
# =============================================================================
echo "🚀 Starting backend services..."
docker compose up -d

echo "⏳ Waiting for API container..."
for i in {1..30}; do
  if docker exec openmemory-openmemory-mcp-1 python -c "print('ready')" >/dev/null 2>&1; then break; fi
  sleep 1
done

# Install vector store packages
install_vector_store_packages() {
  case "$1" in
    qdrant)        docker exec openmemory-openmemory-mcp-1 pip install -q "qdrant-client>=1.9.1" ;;
    chroma)        docker exec openmemory-openmemory-mcp-1 pip install -q "chromadb>=0.4.24" ;;
    weaviate)      docker exec openmemory-openmemory-mcp-1 pip install -q "weaviate-client>=4.4.0,<4.15.0" ;;
    faiss)         docker exec openmemory-openmemory-mcp-1 pip install -q "faiss-cpu>=1.7.4" ;;
    pgvector)      docker exec openmemory-openmemory-mcp-1 pip install -q "vecs>=0.4.0" "psycopg>=3.2.8" ;;
    redis)         docker exec openmemory-openmemory-mcp-1 pip install -q "redis>=5.0.0,<6.0.0" "redisvl>=0.1.0,<1.0.0" ;;
    elasticsearch) docker exec openmemory-openmemory-mcp-1 pip install -q "elasticsearch>=8.0.0,<9.0.0" ;;
    milvus)        docker exec openmemory-openmemory-mcp-1 pip install -q "pymilvus>=2.4.0,<2.6.0" ;;
    opensearch)    docker exec openmemory-openmemory-mcp-1 pip install -q "opensearch-py>=2.0.0" ;;
    *)             docker exec openmemory-openmemory-mcp-1 pip install -q "qdrant-client>=1.9.1" ;;
  esac || echo "⚠️  Failed to install packages for $1 (non-fatal)"
}

echo "📦 Installing vector store packages for $VECTOR_STORE..."
install_vector_store_packages "$VECTOR_STORE"

# =============================================================================
# Seed vector store config via API
# =============================================================================
echo "⏳ Waiting for API to be ready at ${NEXT_PUBLIC_API_URL}..."
for i in {1..60}; do
  if curl -fsS "${NEXT_PUBLIC_API_URL}/api/v1/config/" >/dev/null 2>&1; then break; fi
  sleep 1
done

seed_vector_store_config() {
  local vs=$1
  local dims=$2
  local payload=""

  case "$vs" in
    qdrant)        payload="{\"provider\":\"qdrant\",\"config\":{\"collection_name\":\"openmemory\",\"embedding_model_dims\":${dims},\"host\":\"mem0_store\",\"port\":6333}}" ;;
    chroma)        payload="{\"provider\":\"chroma\",\"config\":{\"collection_name\":\"openmemory\",\"host\":\"mem0_store\",\"port\":8000}}" ;;
    weaviate)      payload="{\"provider\":\"weaviate\",\"config\":{\"collection_name\":\"openmemory\",\"embedding_model_dims\":${dims},\"cluster_url\":\"http://mem0_store:8080\"}}" ;;
    redis)         payload="{\"provider\":\"redis\",\"config\":{\"collection_name\":\"openmemory\",\"embedding_model_dims\":${dims},\"redis_url\":\"redis://mem0_store:6379\"}}" ;;
    pgvector)      payload="{\"provider\":\"pgvector\",\"config\":{\"collection_name\":\"openmemory\",\"embedding_model_dims\":${dims},\"dbname\":\"mem0\",\"user\":\"mem0\",\"password\":\"mem0\",\"host\":\"mem0_store\",\"port\":5432,\"diskann\":false,\"hnsw\":true}}" ;;
    milvus)        payload="{\"provider\":\"milvus\",\"config\":{\"collection_name\":\"openmemory\",\"embedding_model_dims\":${dims},\"url\":\"http://mem0_store:19530\",\"token\":\"\",\"db_name\":\"\",\"metric_type\":\"COSINE\"}}" ;;
    elasticsearch) payload="{\"provider\":\"elasticsearch\",\"config\":{\"collection_name\":\"openmemory\",\"embedding_model_dims\":${dims},\"host\":\"http://mem0_store\",\"port\":9200,\"user\":\"elastic\",\"password\":\"changeme\",\"verify_certs\":false,\"use_ssl\":false}}" ;;
    opensearch)    payload="{\"provider\":\"opensearch\",\"config\":{\"collection_name\":\"openmemory\",\"embedding_model_dims\":${dims},\"host\":\"mem0_store\",\"port\":9200}}" ;;
    faiss)         payload="{\"provider\":\"faiss\",\"config\":{\"collection_name\":\"openmemory\",\"embedding_model_dims\":${dims},\"path\":\"/tmp/faiss\",\"distance_strategy\":\"cosine\"}}" ;;
    *) return ;;
  esac

  echo "🧩 Seeding vector store config ($vs)..."
  curl -fsS -X PUT "${NEXT_PUBLIC_API_URL}/api/v1/config/mem0/vector_store" \
    -H 'Content-Type: application/json' \
    -d "$payload" >/dev/null || echo "⚠️  Could not seed vector store config (non-fatal)"
}

seed_vector_store_config "$VECTOR_STORE" "$EMBEDDING_DIMS"

# Also seed the LLM + embedder config via API
echo "🧩 Seeding LLM config ($LLM_PROVIDER / $LLM_MODEL)..."
curl -fsS -X PUT "${NEXT_PUBLIC_API_URL}/api/v1/config/mem0/llm" \
  -H 'Content-Type: application/json' \
  -d "{\"provider\":\"${LLM_PROVIDER}\",\"config\":{\"model\":\"${LLM_MODEL}\",\"temperature\":0.1,\"max_tokens\":2000,\"api_key\":\"${LLM_API_KEY}\"}}" \
  >/dev/null || echo "⚠️  Could not seed LLM config (non-fatal)"

echo "🧩 Seeding embedder config ($EMBEDDER_PROVIDER / $EMBEDDER_MODEL)..."
curl -fsS -X PUT "${NEXT_PUBLIC_API_URL}/api/v1/config/mem0/embedder" \
  -H 'Content-Type: application/json' \
  -d "{\"provider\":\"${EMBEDDER_PROVIDER}\",\"config\":{\"model\":\"${EMBEDDER_MODEL}\",\"api_key\":\"${EMBEDDER_API_KEY}\"}}" \
  >/dev/null || echo "⚠️  Could not seed embedder config (non-fatal)"

# =============================================================================
# Start UI
# =============================================================================
echo "🚀 Starting frontend on port $FRONTEND_PORT..."
docker run -d \
  --name mem0_ui \
  -p ${FRONTEND_PORT}:3000 \
  -e NEXT_PUBLIC_API_URL="$NEXT_PUBLIC_API_URL" \
  -e NEXT_PUBLIC_USER_ID="$USER" \
  mem0/openmemory-ui:latest

echo ""
echo "✅ Backend:  http://localhost:8765"
echo "✅ Frontend: http://localhost:$FRONTEND_PORT"
echo ""
echo "🤖 LLM:      $LLM_PROVIDER / $LLM_MODEL"
echo "🔢 Embedder: $EMBEDDER_PROVIDER / $EMBEDDER_MODEL"
echo "🧰 Store:    $VECTOR_STORE"
echo ""

# Open browser
URL="http://localhost:$FRONTEND_PORT"
if command -v xdg-open > /dev/null; then xdg-open "$URL"
elif command -v open > /dev/null; then open "$URL"
elif command -v start > /dev/null; then start "$URL"
else echo "⚠️  Open $URL manually."
fi
