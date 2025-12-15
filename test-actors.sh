#!/usr/bin/env bash
# Smoke-test registered actors by sending a blocking message and printing the response.
# Usage:
#   ./test-actors.sh            # test all known actors with sample payloads
#   ./test-actors.sh whisper    # test only the whisper actor

# Avoid nounset because we guard lookups manually.
set -eo pipefail

TAPIS_BASE_URL="${TAPIS_BASE_URL:-https://tacc.tapis.io}"

if [[ -z "${TAPIS_TOKEN:-}" ]]; then
  echo "TAPIS_TOKEN is required (tenant-scoped token with message permissions)." >&2
  exit 1
fi

actor_id_for() {
  local key="$1"
  case "$key" in
    multi_narrative) echo "${MULTI_NARRATIVE_ACTOR_ID:-}" ;;
    semantic_bridge) echo "${SEMANTIC_BRIDGE_ACTOR_ID:-}" ;;
    whisper)         echo "${WHISPER_ACTOR_ID:-}" ;;
    *) echo "" ;;
  esac
}

sample_payload() {
  local key="$1"
  case "$key" in
    multi_narrative)
      cat <<'EOF'
{"text":"Flooding is getting worse near the river after each storm.","params":{"num_topics":3}}
EOF
      ;;
    semantic_bridge)
      cat <<'EOF'
{"text":"Residents report saline taste in wells and want water quality testing.","params":{"backbone":"default"}}
EOF
      ;;
    whisper)
      cat <<'EOF'
{"audio_path":"/staged/audio.wav","language":"en","model":"base"}
EOF
      ;;
    *)
      echo "{}"
      ;;
  esac
}

send_message() {
  local key="$1"
  local actor_id="$2"
  local payload
  payload="$(sample_payload "$key")"

  echo "Testing ${key} (${actor_id})..."
  local resp status
  resp="$(mktemp)"
  status="$(curl -sS -o "${resp}" -w "%{http_code}" \
    -X POST "${TAPIS_BASE_URL}/v3/actors/${actor_id}/messages?blocking=true&timeout=60" \
    -H "Content-Type: application/json" \
    -H "X-Tapis-Token: ${TAPIS_TOKEN}" \
    -d "${payload}")"

  if [[ "${status}" != "200" && "${status}" != "201" ]]; then
    echo "✗ ${key} failed (HTTP ${status})" >&2
    cat "${resp}" >&2
    rm -f "${resp}"
    exit 1
  fi

  echo "✓ ${key} response:"
  cat "${resp}"
  echo
  rm -f "${resp}"
}

targets=("$@")
if [[ ${#targets[@]} -eq 0 ]]; then
  targets=("multi_narrative" "semantic_bridge" "whisper")
fi

for key in "${targets[@]}"; do
  actor_id="$(actor_id_for "$key")"
  if [[ -z "${actor_id}" ]]; then
    echo "Missing actor ID for ${key}. Set ${key^^}_ACTOR_ID (e.g., MULTI_NARRATIVE_ACTOR_ID)." >&2
    exit 1
  fi
  send_message "$key" "$actor_id"
done
