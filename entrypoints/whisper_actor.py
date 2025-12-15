#!/usr/bin/env python3
"""
Tapis Actor entrypoint for Whisper transcription.

Expected message (JSON):
{
  "audio_path": "/path/to/audio",  # staged audio file
  "language": "en",                # optional language hint
  "model": "base"                  # optional Whisper model size
}

Output (JSON) is a manifest with transcript text and artifact locations.
"""

import json
import sys
from typing import Any, Dict


def run_whisper(payload: Dict[str, Any]) -> Dict[str, Any]:
    # Placeholder: integrate with whisper-container invocation (e.g., `python run.py`).
    audio_path = payload.get("audio_path")
    language = payload.get("language")
    model = payload.get("model", "base")

    return {
        "workflow": "whisper_transcription",
        "status": "completed",
        "summary": "Stub manifest; replace with real Whisper transcript.",
        "params": {"language": language, "model": model},
        "transcript": "",
        "segments": [],
        "artifacts": [
            # e.g., {"type": "text", "url": ".../transcript.txt"}
        ],
        "metadata": {
            "audio_path": audio_path,
        },
    }


def main() -> None:
    payload = {}
    if not sys.stdin.isatty():
        try:
            payload = json.load(sys.stdin)
        except Exception:
            payload = {}

    result = run_whisper(payload)
    json.dump(result, sys.stdout)


if __name__ == "__main__":
    main()
