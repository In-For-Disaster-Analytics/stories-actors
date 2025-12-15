#!/usr/bin/env bash
# Registers Stories UI workflow actors (multi-narrative, semantic-bridge, whisper) on the tacc.tapis.io tenant.
# Uses the Tapis Actors v3 HTTP API directly so you only need curl and a scoped token.

# Avoid nounset here because we do indirect expansion; we guard variables manually.
set -eo pipefail

if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "Please run with bash (e.g., 'bash register-actors.sh whisper')." >&2
  exit 1
fi

TAPIS_BASE_URL="${TAPIS_BASE_URL:-https://tacc.tapis.io}"
ACTOR_PREFIX="${ACTOR_PREFIX:-stories}"
ACTOR_OWNER="${ACTOR_OWNER:-stories-ui}"
# Location of Python actor entrypoints (for reference/packaging).
ACTOR_CODE_DIR="${ACTOR_CODE_DIR:-entrypoints}"

# Required: bearer token with actors:create and actors:admin on the tenant.
if [[ -z "${TAPIS_TOKEN:-}" ]]; then
  echo "TAPIS_TOKEN is required (tenant-scoped token with actors permissions)." >&2
  exit 1
fi

require_image() {
  local var_name="$1"
  local val="${!var_name:-}"
  if [[ -z "$val" ]]; then
    echo "Set $var_name to the container image (e.g., ghcr.io/yourorg/multi-narrative:latest)." >&2
    exit 1
  fi
}

create_actor() {
  local key="$1" name="$2" image="$3" description="$4"
  local actor_name="${ACTOR_PREFIX}-${name}"
  local payload
  payload="$(cat <<EOF
{
  "name": "${actor_name}",
  "image": "${image}",
  "description": "${description}",
  "default_environment": {
    "WORKFLOW_KEY": "${key}",
    "ACTOR_OWNER": "${ACTOR_OWNER}"
  },
  "force": true
}
EOF
)"

  echo "Registering actor ${actor_name}..."
  local resp status
  resp="$(mktemp)"
  status="$(curl -sS -o "${resp}" -w "%{http_code}" \
    -X POST "${TAPIS_BASE_URL}/v3/actors" \
    -H "Content-Type: application/json" \
    -H "X-Tapis-Token: ${TAPIS_TOKEN}" \
    -d "${payload}")"

  if [[ "${status}" != "200" && "${status}" != "201" ]]; then
    echo "✗ Failed to create ${actor_name} (HTTP ${status})" >&2
    cat "${resp}" >&2
    rm -f "${resp}"
    exit 1
  fi

  echo "✓ ${actor_name} registered"
  cat "${resp}"
  rm -f "${resp}"
}

register_actor() {
  local key="$1"
  local image_var=""
  local description=""
  local actor_key=""
  local actor_name=""

  case "$key" in
    multi_narrative)
      image_var="MULTI_NARRATIVE_IMAGE"
      description="Stories UI - multi narrative analysis"
      actor_key="multi_narrative"
      actor_name="multi-narrative"
      ;;
    semantic_bridge)
      image_var="SEMANTIC_BRIDGE_IMAGE"
      description="Stories UI - semantic bridge SVO mapping"
      actor_key="semantic_bridge"
      actor_name="semantic-bridge"
      ;;
    whisper)
      image_var="WHISPER_IMAGE"
      description="Stories UI - Whisper transcription"
      actor_key="whisper_transcribe"
      actor_name="whisper"
      ;;
    *)
      echo "Unknown actor key: ${key}. Valid keys: multi_narrative semantic_bridge whisper" >&2
      exit 1
      ;;
  esac

  local image="${!image_var:-}"
  if [[ -z "${image}" ]]; then
    echo "Missing image for ${key}. Set ${image_var}." >&2
    exit 1
  fi

  create_actor "${actor_key}" "${actor_name}" "${image}" "${description}"
}

targets=("$@")
if [[ ${#targets[@]} -eq 0 ]]; then
  targets=("multi_narrative" "semantic_bridge" "whisper")
fi

if [[ ! -d "${ACTOR_CODE_DIR}" ]]; then
  echo "Note: actor code directory '${ACTOR_CODE_DIR}' not found. Set ACTOR_CODE_DIR if you keep entrypoints elsewhere." >&2
fi

for key in "${targets[@]}"; do
  register_actor "${key}"
done
