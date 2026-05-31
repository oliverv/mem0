# Build context: repo root (mem0/)
FROM python:3.12-slim

LABEL org.opencontainers.image.name="mem0/openmemory-mcp-dev"

WORKDIR /usr/src/openmemory

# Install API deps, skipping mem0ai (we install from local source below)
COPY openmemory/api/requirements.txt .
RUN grep -v "^mem0ai" requirements.txt > requirements.filtered.txt \
    && pip install -r requirements.filtered.txt

# Install local mem0 source (so our xAI changes are live)
COPY pyproject.toml README.md /tmp/mem0/
COPY mem0 /tmp/mem0/mem0
RUN pip install --upgrade pip hatchling && pip install /tmp/mem0

# Copy API source
COPY openmemory/api/ .

EXPOSE 8765
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8765"]
