#!/bin/sh
set -eu

CONFIG_DIR="/app/config"
mkdir -p "$CONFIG_DIR"

if [ -z "${ASF_IPC_PASSWORD:-}" ]; then
  echo "ERROR: ASF_IPC_PASSWORD is required."
  exit 1
fi

json_escape() {
  printf '%s' "$1" | sed \
    -e 's/\\/\\\\/g' \
    -e 's/"/\\"/g' \
    -e 's/\r/\\r/g' \
    -e ':a;N;$!ba;s/\n/\\n/g'
}

IPC_PASSWORD_ESCAPED="$(json_escape "$ASF_IPC_PASSWORD")"

if [ ! -f "$CONFIG_DIR/ASF.json" ] || [ "${REGENERATE_CONFIG:-false}" = "true" ]; then
  cat > "$CONFIG_DIR/ASF.json" <<EOF
{
  "IPC": true,
  "IPCPassword": "${IPC_PASSWORD_ESCAPED}",
  "UpdateChannel": 1
}
EOF
fi

if [ ! -f "$CONFIG_DIR/IPC.config" ] || [ "${REGENERATE_CONFIG:-false}" = "true" ]; then
  cat > "$CONFIG_DIR/IPC.config" <<'EOF'
{
  "Kestrel": {
    "Endpoints": {
      "HTTP": {
        "Url": "http://*:1242"
      }
    }
  }
}
EOF
fi

make_bot() {
  BOT_NAME="$1"
  BOT_LOGIN="$2"
  BOT_PASSWORD="$3"
  BOT_ENABLED="$4"

  [ -n "$BOT_LOGIN" ] || return 0

  BOT_LOGIN_ESCAPED="$(json_escape "$BOT_LOGIN")"
  BOT_PASSWORD_ESCAPED="$(json_escape "$BOT_PASSWORD")"
  BOT_FILE="$CONFIG_DIR/${BOT_NAME}.json"

  if [ ! -f "$BOT_FILE" ] || [ "${REGENERATE_CONFIG:-false}" = "true" ]; then
    cat > "$BOT_FILE" <<EOF
{
  "Enabled": ${BOT_ENABLED},
  "SteamLogin": "${BOT_LOGIN_ESCAPED}",
  "SteamPassword": "${BOT_PASSWORD_ESCAPED}",
  "UseLoginKeys": true,
  "OnlineStatus": 1,
  "FarmingPreferences": 0
}
EOF
  fi
}

make_bot "${BOT1_NAME:-Account1}" "${BOT1_LOGIN:-}" "${BOT1_PASSWORD:-}" "${BOT1_ENABLED:-true}"
make_bot "${BOT2_NAME:-Account2}" "${BOT2_LOGIN:-}" "${BOT2_PASSWORD:-}" "${BOT2_ENABLED:-true}"

chown -R 1000:1000 "$CONFIG_DIR" 2>/dev/null || true

echo "Starting ArchiSteamFarm..."
exec ArchiSteamFarm --no-restart
