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

validate_bool() {
  case "$1" in
    true|false)
      printf '%s' "$1"
      ;;
    *)
      echo "ERROR: Invalid boolean value: $1" >&2
      exit 1
      ;;
  esac
}

IPC_PASSWORD_ESCAPED="$(json_escape "$ASF_IPC_PASSWORD")"

PAM_ENABLED_JSON="$(validate_bool "${PAM_ENABLED:-true}")"
PAM_DRY_RUN_JSON="$(validate_bool "${PAM_DRY_RUN:-true}")"
PAM_RANDOM_PLAY_JSON="$(validate_bool "${PAM_RANDOM_PLAY_ENABLED:-false}")"
PAM_FRIEND_REQUESTS_JSON="$(validate_bool "${PAM_FRIEND_REQUESTS_ENABLED:-false}")"

if [ ! -f "$CONFIG_DIR/ASF.json" ] || [ "${REGENERATE_CONFIG:-false}" = "true" ]; then
  cat > "$CONFIG_DIR/ASF.json" <<EOF
{
  "IPC": true,
  "IPCPassword": "${IPC_PASSWORD_ESCAPED}",
  "Headless": true,
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
  BOT_ENABLED_JSON="$(validate_bool "$BOT_ENABLED")"
  BOT_FILE="$CONFIG_DIR/${BOT_NAME}.json"

  if [ ! -f "$BOT_FILE" ] || [ "${REGENERATE_CONFIG:-false}" = "true" ]; then
    cat > "$BOT_FILE" <<EOF
{
  "Enabled": ${BOT_ENABLED_JSON},
  "SteamLogin": "${BOT_LOGIN_ESCAPED}",
  "SteamPassword": "${BOT_PASSWORD_ESCAPED}",
  "UseLoginKeys": true,
  "OnlineStatus": 1,
  "FarmingPreferences": 0,
  "GamesPlayedWhileIdle": [],

  "PersonalAccountManager": {
    "Enabled": ${PAM_ENABLED_JSON},
    "DryRun": ${PAM_DRY_RUN_JSON},

    "RandomPlay": {
      "Enabled": ${PAM_RANDOM_PLAY_JSON},
      "OwnerIdleGraceMinutes": 5,
      "OwnerActiveDebounceSeconds": 10,
      "ResumeAfterAwayMinutes": 5,
      "MinimumPlayMinutes": 30,
      "MaximumPlayMinutes": 120,
      "DelayBetweenGamesSeconds": 15,
      "NoRepeatGameCount": 20,
      "AppIDAllowlist": [],
      "AppIDBlacklist": [],
      "IncludeFreeGames": true,
      "IncludeFamilySharedGames": false
    },

    "FriendRequests": {
      "Enabled": ${PAM_FRIEND_REQUESTS_JSON},
      "RequireProfileComment": true,
      "MinimumSteamLevel": 5,
      "RejectCommunityBanned": true,
      "RejectEconomyRestricted": true,
      "MaximumVacBans": 1,
      "MaximumGameBans": 1,
      "RejectBanNewerThanDays": 180,
      "UnknownLevelPolicy": "KeepPending",
      "UnknownBanStatusPolicy": "KeepPending",
      "EvaluationIntervalMinutes": 15,
      "RequestExpirationHours": 72,
      "MaximumEvaluationAttempts": 12,
      "RejectOnExpiration": false,
      "Whitelist": [],
      "Blacklist": []
    },

    "Notifications": {
      "LogDecisions": true,
      "DiscordWebhookEnabled": false
    }
  }
}
EOF
  fi
}

make_bot \
  "${BOT1_NAME:-main}" \
  "${BOT1_LOGIN:-}" \
  "${BOT1_PASSWORD:-}" \
  "${BOT1_ENABLED:-true}"

make_bot \
  "${BOT2_NAME:-Account2}" \
  "${BOT2_LOGIN:-}" \
  "${BOT2_PASSWORD:-}" \
  "${BOT2_ENABLED:-true}"

chown -R 1000:1000 "$CONFIG_DIR" 2>/dev/null || true

echo "Starting ArchiSteamFarm..."
exec ArchiSteamFarm --no-restart