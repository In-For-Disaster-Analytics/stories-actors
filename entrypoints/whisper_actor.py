#!/usr/bin/env python3
"""
Tapis Actor entrypoint for Whisper transcription using openai-whisper.

Expected message (JSON):
{
  "audio_path": "/path/to/audio",  # staged audio file
  "language": "en",                # optional language hint
  "model": "base"                  # optional Whisper model size
}

Output (JSON) is a manifest with transcript text and artifact locations.
"""

import json
import os
import sys
from typing import Any, Dict

import whisper


def run_whisper(payload: Dict[str, Any]) -> Dict[str, Any]:
    audio_path = payload.get("audio_path")
    language = payload.get("language")
    model_size = payload.get("model", "base")

    if not audio_path or not os.path.exists(audio_path):
        return {
            "workflow": "whisper_transcription",
            "status": "error",
            "error": f"audio_path missing or not found: {audio_path}",
        }

    model = whisper.load_model(model_size)
    result = model.transcribe(audio_path, language=language)

    return {
        "workflow": "whisper_transcription",
        "status": "completed",
        "summary": "Whisper transcript",
        "params": {"language": language, "model": model_size},
        "transcript": result.get("text", ""),
        "segments": result.get("segments", []),
        "artifacts": [],
        "metadata": {
            "audio_path": audio_path,
            "duration": result.get("duration"),
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
