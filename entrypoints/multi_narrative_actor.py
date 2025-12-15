#!/usr/bin/env python3
"""
Tapis Actor entrypoint for multi-narrative analysis.

Expected message (JSON):
{
  "text": "...",               # optional inline text
  "input_path": "/path/to/file",  # optional staged file
  "params": {...}              # pipeline parameters (num_topics, language, etc.)
}

Output (JSON) is a normalized manifest for the Stories UI, containing either inline results
or URLs to artifacts uploaded by this actor (e.g., CKAN/object storage).
"""

import json
import os
import sys
from typing import Any, Dict


def run_analysis(payload: Dict[str, Any]) -> Dict[str, Any]:
    # Placeholder: wire this to the actual multi-narrative analysis CLI or Python API.
    # Example: subprocess.run(["python", "/code/main.py", ...])
    text = payload.get("text") or ""
    params = payload.get("params") or {}

    # Stub manifest for now; replace with real outputs from the pipeline.
    return {
        "workflow": "multi_narrative",
        "status": "completed",
        "summary": "Stub manifest; replace with real pipeline outputs.",
        "params": params,
        "insights": {
            "sentiment": {"compound": 0.0},
            "topics": [],
            "key_events": [],
        },
        "artifacts": [],
        "metadata": {
            "input_chars": len(text),
        },
    }


def main() -> None:
    payload = {}
    if not sys.stdin.isatty():
        try:
            payload = json.load(sys.stdin)
        except Exception:
            payload = {}

    result = run_analysis(payload)
    json.dump(result, sys.stdout)


if __name__ == "__main__":
    main()
