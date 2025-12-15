#!/usr/bin/env bash
set -euo pipefail

# Allow overriding the actor script path
SCRIPT="${ENTRYPOINT_SCRIPT:-/app/whisper_actor.py}"
python3 "$SCRIPT"
