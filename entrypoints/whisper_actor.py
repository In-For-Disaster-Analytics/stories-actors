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
import tempfile
from typing import Any, Dict
from urllib.parse import urlparse
import urllib.request

import whisper


def run_whisper(payload: Dict[str, Any]) -> Dict[str, Any]:
    audio_path = payload.get("audio_path")
    language = payload.get("language")
    model_size = payload.get("model", "base")

    temp_path = None
    if audio_path and audio_path.startswith(("http://", "https://")):
        try:
            parsed = urlparse(audio_path)
            suffix = os.path.splitext(parsed.path)[-1]
            tmp = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
            urllib.request.urlretrieve(audio_path, tmp.name)
            temp_path = tmp.name
            audio_path = temp_path
        except Exception as e:
            return {
                "workflow": "whisper_transcription",
                "status": "error",
                "error": f"failed to download audio_url: {e}",
            }

    if not audio_path or not os.path.exists(audio_path):
        if temp_path and os.path.exists(temp_path):
            os.unlink(temp_path)
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

    if temp_path and os.path.exists(temp_path):
        os.unlink(temp_path)


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
