# Placeholder Dockerfile for CPU-based NLP actors (multi-narrative, semantic-bridge).
# Replace with your real pipeline dependencies and code copy steps.

FROM python:3.10-slim

WORKDIR /app

# System deps (extend as needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Copy actor entrypoints (override at build time if needed)
COPY ../../entrypoints/multi_narrative_actor.py /app/multi_narrative_actor.py
COPY ../../entrypoints/semantic_bridge_actor.py /app/semantic_bridge_actor.py

# Install workflow dependencies here (pip/conda) and copy your pipeline code/models.
# Example:
# COPY requirements.txt /app/requirements.txt
# RUN pip install -r requirements.txt
# COPY your_pipeline/ /app/your_pipeline/

# Default entrypoint; override with ENTRYPOINT_SCRIPT env at runtime if desired.
ENV ENTRYPOINT_SCRIPT=/app/multi_narrative_actor.py
ENTRYPOINT ["python", "/app/multi_narrative_actor.py"]
