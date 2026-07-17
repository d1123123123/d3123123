#!/bin/sh
set -eu

CONFIG_DIR="/app/config"
mkdir -p "$CONFIG_DIR"

if [ -z "${ASF_IPC_PASSWORD:-}" ]; then
  echo "ERROR: Railway variable ASF_IPC_PASSWORD is required."
  exit 1
fi

# Global ASF configuration. Existing files are preserved unless
# REGENERATE_CONFIG=true is explicitly set.
if [ ! -f "$CONFIG_DIR/ASF.json" ] || [ "${REGENERATE_CONFIG:-false}" = "true" ]; then
  cat > "$CONFIG_DIR/ASF.json" <<EOF
{
  "IPC": true,
  "IPCPassword": "${ASF_IPC_PASSWORD}",
  "UpdateChannel": 1
}
EOF
fi

# Make ASF's web interface reachable through Railway networking.
if [ ! -f "$CONFIG_DIR/IPC.config" ] || [ "${REGENERATE_CONFIG:-false}" = "true" ]; then
  cat > "$CONFIG_DIR/IPC.config" <<'EOF'
{
  "Kestrel": {
    "Endpoints": {
      "HTTP": {
        "Url": "http://0.0.0.0:1242"
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

  BOT_FILE="$CONFIG_DIR/${BOT_NAME}.json"
  if [ ! -f "$BOT_FILE" ] || [ "${REGENERATE_CONFIG:-false}" = "true" ]; then
    # JSON-escape credentials using ASF's bundled .NET runtime is overkill here;
    # reject unsafe characters instead of silently creating malformed JSON.
    case "$BOT_LOGIN$BOT_PASSWORD" in
      *\"*|*\\*|*
*) echo "ERROR: Steam credentials cannot contain quote, backslash, or newline in this starter."; exit 1 ;;
    esac

    cat > "$BOT_FILE" <<EOF
{
  "Enabled": ${BOT_ENABLED},
  "SteamLogin": "${BOT_LOGIN}",
  "SteamPassword": "${BOT_PASSWORD}",
  "UseLoginKeys": true,
  "OnlineStatus": 1,
  "FarmingPreferences": 0
}
EOF
  fi
}

make_bot "${BOT1_NAME:-Account1}" "${BOT1_LOGIN:-}" "${BOT1_PASSWORD:-}" "${BOT1_ENABLED:-true}"
make_bot "${BOT2_NAME:-Account2}" "${BOT2_LOGIN:-}" "${BOT2_PASSWORD:-}" "${BOT2_ENABLED:-true}"

# Avoid leaving generated files owned by root when the mounted volume is new.
chown -R 1000:1000 "$CONFIG_DIR" 2>/dev/null || true

cd /app
if [ -x /app/ArchiSteamFarm ]; then
  exec /app/ArchiSteamFarm
elif [ -f /app/ArchiSteamFarm.dll ]; then
  exec dotnet /app/ArchiSteamFarm.dll
else
  echo "ERROR: ASF executable was not found in the official image."
  exit 1
fi
