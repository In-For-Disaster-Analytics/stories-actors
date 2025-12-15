# Placeholder GPU-capable Whisper actor image.
# Replace base image and install the actual Whisper stack (e.g., torch + whisper/insanely-fast-whisper).

FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv ffmpeg curl \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoints/whisper_actor.py /app/whisper_actor.py
COPY images/whisper/requirements.txt /app/requirements.txt
COPY images/whisper/entrypoint.sh /app/entrypoint.sh

# Install Python deps and copy model code here.
RUN python3 -m pip install --no-cache-dir -r /app/requirements.txt

ENTRYPOINT ["/app/entrypoint.sh"]
