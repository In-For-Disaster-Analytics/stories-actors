## Stories Actors

Containerized Tapis Actors for Stories UI workflows. This repo holds the Python entrypoints and build workflows for:
- Multi-narrative analysis (CPU)
- Semantic bridge (SVO) mapping (CPU)
- Whisper transcription (GPU)

### Layout
- `entrypoints/` — Python actor stubs; read JSON from stdin, emit JSON to stdout.
- `images/nlp/` — Docker context for CPU NLP actors (multi-narrative, semantic bridge).
- `images/whisper/` — Docker context for GPU Whisper actor.
- `.github/workflows/` — CI to build/push images (GHCR by default).

### Building locally
```bash
# NLP (default entrypoint: multi_narrative; override ENTRYPOINT_SCRIPT env to switch)
docker build -t stories-nlp-actor:local images/nlp

# Whisper (GPU-capable base recommended)
docker build -t stories-whisper-actor:local images/whisper
```

### Registering actors
Use the scripts copied from the former UI repo (or recreate) to register images on `tacc.tapis.io`:
```bash
export TAPIS_TOKEN=...   # actors:create/admin
export MULTI_NARRATIVE_IMAGE=ghcr.io/yourorg/stories-nlp-actor:latest
export SEMANTIC_BRIDGE_IMAGE=ghcr.io/yourorg/stories-nlp-actor:latest
export WHISPER_IMAGE=ghcr.io/yourorg/stories-whisper-actor:latest
bash register-actors.sh             # all
bash register-actors.sh whisper     # single
```

### CI workflows
Two workflows build/push images to GHCR:
- `build-nlp.yml` (cpu) -> `ghcr.io/<owner>/stories-nlp-actor:latest`
- `build-whisper.yml` (gpu) -> `ghcr.io/<owner>/stories-whisper-actor:latest`

Set repository secrets if you need an external registry; GHCR works with `GITHUB_TOKEN`.

### Next steps
- Wire the entrypoints to real pipelines (multi-narrative-analysis, semantic-bridge-demo, whisper-container).
- Add model weights/runtime dependencies to the Dockerfiles.
- Update registration env vars in Stories UI to point at the published actor IDs.
