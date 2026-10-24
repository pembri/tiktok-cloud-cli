#!/data/data/com.termux/files/usr/bin/bash
# TikTok Cloud CLI installer for Termux (single file)
# Usage: ./install.sh

APP="tiktok-cloud"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
BIN="$PREFIX/bin/$APP"
OUT_DIR="/sdcard/Download/tiktok-cloud"
RECORD="$HOME/.tiktok-cloud"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

API_BASE="https://riracloud.my.id/api/tiktok-cloud-cli"
API_KEY="affce98116967574265b199a5b10d344829e6dbb661a6f186b3ec398bf9722aa"
REPO_URL="https://github.com/pembri/tiktok-cloud-cli"

if [ -t 1 ]; then
  C_B=$'\033[1;36m'; C_G=$'\033[32m'; C_R=$'\033[31m'; C_0=$'\033[0m'
else
  C_B=""; C_G=""; C_R=""; C_0=""
fi

WIDTH=30
STATE_DIR="$(mktemp -d)"
cleanup() { rm -rf "$STATE_DIR"; }
trap cleanup EXIT

DONE_STEPS=()
LAST_LINES=0

draw_bar() {
  local pct=$1 label=$2
  local filled=$(( pct * WIDTH / 100 ))
  local empty=$(( WIDTH - filled ))
  local bar="" i
  for ((i = 0; i < filled; i++)); do bar+="#"; done
  for ((i = 0; i < empty; i++)); do bar+="-"; done
  printf '%s[%s]%s %3d%%  %s' "$C_B" "$bar" "$C_0" "$pct" "$label"
}

# Redraws the whole block in place: completed steps as checkmarks, then
# the live progress bar for the step currently running.
render() {
  local pct="$1" label="$2"
  if [ "$LAST_LINES" -gt 0 ]; then
    printf '\033[%dA\033[J' "$LAST_LINES"
  fi
  local item
  for item in "${DONE_STEPS[@]}"; do
    printf '%s✔%s %s\n' "$C_G" "$C_0" "$item"
  done
  draw_bar "$pct" "$label"
  echo
  LAST_LINES=$(( ${#DONE_STEPS[@]} + 1 ))
}

# Final redraw once everything is done: checklist only, no bar line left behind.
finish_render() {
  if [ "$LAST_LINES" -gt 0 ]; then
    printf '\033[%dA\033[J' "$LAST_LINES"
  fi
  local item
  for item in "${DONE_STEPS[@]}"; do
    printf '%s✔%s %s\n' "$C_G" "$C_0" "$item"
  done
  LAST_LINES=0
}

die() {
  finish_render
  printf '\n%s✖ %s%s\n' "$C_R" "$1" "$C_0"
  exit 1
}

# Runs "$@" in the background while animating the bar from $2 to $3-1,
# then snaps to $3 when the job finishes. On success, marks the step done
# (so it becomes a permanent checklist line) and returns 0; else returns 1.
run_step() {
  local label="$1" start="$2" end="$3"; shift 3
  render "$start" "$label"
  ( "$@" ) >"$STATE_DIR/log" 2>&1 &
  local pid=$!
  local pct=$start
  while kill -0 "$pid" 2>/dev/null; do
    sleep 0.2
    if [ "$pct" -lt $(( end - 1 )) ]; then pct=$(( pct + 1 )); fi
    render "$pct" "$label"
  done
  wait "$pid"
  local rc=$?
  render "$end" "$label"
  if [ "$rc" -eq 0 ]; then
    DONE_STEPS+=("$label")
  fi
  return $rc
}

print_header() {
  local C_W="" C_M="" C_L="" C_Y="" C_BL=""
  if [ -n "$C_B" ]; then C_W=$'\033[1;97m'; C_M=$'\033[1;95m'; C_L=$'\033[96m'; C_Y=$'\033[1;93m'; C_BL=$'\033[1;94m'; fi
  local line
  while IFS= read -r line; do printf '%s%s%s\n' "$C_B" "$line" "$C_0"; done <<'LOGO'
 ########\##\ ##\         ##\               ##\       
\__##  __|\__|## |        ## |              ## |      
   ## |   ##\ ## |  ##\ ######\    ######\  ## |  ##\ 
   ## |   ## |## | ##  |\_##  _|  ##  __##\ ## | ##  |
   ## |   ## |######  /   ## |    ## /  ## |######  / 
   ## |   ## |##  _##<    ## |##\ ## |  ## |##  _##<  
   ## |   ## |## | \##\   \####  |\######  |## | \##\ 
   \__|   \__|\__|  \__|   \____/  \______/ \__|  \__|
 ######\  ##\                           ##\           
##  __##\ ## |                          ## |          
## /  \__|## | ######\  ##\   ##\  ####### |          
## |      ## |##  __##\ ## |  ## |##  __## |          
## |      ## |## /  ## |## |  ## |## /  ## |          
## |  ##\ ## |## |  ## |## |  ## |## |  ## |          
\######  |## |\######  |\######  |\####### |          
 \______/ \__| \______/  \______/  \_______|          
LOGO
  echo
  local t="TikTok Cloud CLI" s="TikTok Video Downloader For Termux"
  local d="Rira Project" g="$REPO_URL"
  local w=$(( ${#g} + 12 )) x
  for x in "$t" "$s" "Developed : $d"; do [ "${#x}" -gt "$w" ] && w=${#x}; done
  w=$(( w + 4 ))
  local EL="${C_B}##${C_0}" ER="${C_B}## |${C_0}"
  local hash us
  hash="$(printf '%*s' $(( w + 4 )) '' | tr ' ' '#')"
  printf '%s%s\\%s\n' "$C_B" "$hash" "$C_0"
  centered() {
    local txt="$1" col="$2" pad=$(( w - ${#1} ))
    local left=$(( pad / 2 )) right=$(( pad - pad / 2 ))
    printf '%s%*s%s%s%s%*s%s\n' "$EL" "$left" '' "$col" "$txt" "$C_0" "$right" '' "$ER"
  }
  kv() {
    local label="$1" val="$2" vcol="$3"
    local plain="$label : $val" pad
    pad=$(( w - ${#plain} - 2 ))
    printf '%s  %s%s%s : %s%s%s%*s%s\n' "$EL" "$C_L" "$label" "$C_0" "$vcol" "$val" "$C_0" "$pad" '' "$ER"
  }
  centered "$t" "$C_W"
  centered "$s" "$C_M"
  printf '%s%*s%s\n' "$EL" "$w" '' "$ER"
  kv "Developed" "$d" "$C_Y"
  kv "Github   " "$g" "$C_BL"
  us="$(printf '%*s' $(( w + 2 )) '' | tr ' ' '_')"
  hash="$(printf '%*s' $(( w + 3 )) '' | tr ' ' '#')"
  printf '%s\\%s |%s\n' "$C_B" "$hash" "$C_0"
  printf '%s \\%s/%s\n' "$C_B" "$us" "$C_0"
  echo
}

print_header

render 0 "Checking environment"
if ! { [ -d "$PREFIX/bin" ] && command -v pkg >/dev/null 2>&1; }; then
  die "This installer is for Termux only."
fi
render 5 "Checking environment"
DONE_STEPS+=("Checking environment")

HAD_PYTHON=0; command -v python3 >/dev/null 2>&1 && HAD_PYTHON=1
HAD_FFMPEG=0; command -v ffmpeg >/dev/null 2>&1 && HAD_FFMPEG=1
HAD_DENO=0; command -v deno >/dev/null 2>&1 && HAD_DENO=1
HAD_YTDLP=0; command -v yt-dlp >/dev/null 2>&1 && HAD_YTDLP=1

prepare_env() {
  apt-get update >/dev/null 2>&1
  pkg install -y python ffmpeg >/dev/null 2>&1 || return 1
  pkg install -y deno >/dev/null 2>&1
  if python3 -m pip install -U yt-dlp >/dev/null 2>&1; then :
  elif python3 -m pip install -U --break-system-packages yt-dlp >/dev/null 2>&1; then :
  elif pkg install -y yt-dlp >/dev/null 2>&1; then :
  else return 1
  fi
  command -v python3 >/dev/null 2>&1 || return 1
  command -v ffmpeg >/dev/null 2>&1 || return 1
  command -v yt-dlp >/dev/null 2>&1 || return 1
  return 0
}
export -f prepare_env

run_step "Preparing environment" 5 65 bash -c prepare_env \
  || die "Could not prepare the environment. Check your internet connection and try again."

NEW_PKGS=""
[ "$HAD_PYTHON" = 0 ] && command -v python3 >/dev/null 2>&1 && NEW_PKGS="$NEW_PKGS python"
[ "$HAD_FFMPEG" = 0 ] && command -v ffmpeg >/dev/null 2>&1 && NEW_PKGS="$NEW_PKGS ffmpeg"
[ "$HAD_DENO" = 0 ] && command -v deno >/dev/null 2>&1 && NEW_PKGS="$NEW_PKGS deno"
NEW_YTDLP=0
[ "$HAD_YTDLP" = 0 ] && command -v yt-dlp >/dev/null 2>&1 && NEW_YTDLP=1

storage_wait() {
  mkdir -p "$OUT_DIR" 2>/dev/null
  [ -w "$OUT_DIR" ] && return 0
  termux-setup-storage >/dev/null 2>&1
  local i
  for i in $(seq 1 45); do
    sleep 2
    mkdir -p "$OUT_DIR" 2>/dev/null
    [ -w "$OUT_DIR" ] && return 0
  done
  return 1
}
export -f storage_wait
export OUT_DIR

run_step "Checking storage access" 65 85 bash -c storage_wait \
  || die "No access to /sdcard. Run 'termux-setup-storage', tap Allow, then run ./install.sh again."

fetch_cmd() {
  command -v curl >/dev/null 2>&1 || pkg install -y curl >/dev/null 2>&1
  command -v curl >/dev/null 2>&1 || return 1
  local code
  code="$(curl -sS -o "$BIN.new" -w '%{http_code}' -H "X-TIKTOK-CLOUD-KEY: $API_KEY" "$API_BASE/download")"
  echo "$code" > "$STATE_DIR/http_code"
  [ "$code" = "200" ] && [ -s "$BIN.new" ]
}
export -f fetch_cmd
export BIN API_KEY API_BASE STATE_DIR

if ! run_step "Fetching the tiktok-cloud command" 85 100 bash -c fetch_cmd; then
  CODE="$(cat "$STATE_DIR/http_code" 2>/dev/null || echo '000')"
  rm -f "$BIN.new"
  die "Could not fetch tiktok-cloud (HTTP $CODE). Check your internet connection and try again."
fi

finish_render
echo

chmod 755 "$BIN.new"
mv -f "$BIN.new" "$BIN" || die "Could not install $BIN"

REMOTE_VERSION="$(curl -sS -H "X-TIKTOK-CLOUD-KEY: $API_KEY" "$API_BASE/version" 2>/dev/null)"
PREV=""
[ -f "$RECORD" ] && PREV="$(grep -E '^(pkg|pip):' "$RECORD" 2>/dev/null)"
{
  printf '%s\n' "$REPO_URL"
  {
    printf '%s\n' "$PREV"
    for p in $NEW_PKGS; do printf 'pkg:%s\n' "$p"; done
    [ "$NEW_YTDLP" = 1 ] && printf 'pip:yt-dlp\n'
  } | grep -E '^(pkg|pip):' | sort -u
} > "$RECORD.tmp" && mv "$RECORD.tmp" "$RECORD"
hash -r 2>/dev/null

FOUND="$(command -v tiktok-cloud 2>/dev/null)"
if [ -n "$FOUND" ] && [ "$FOUND" != "$BIN" ]; then
  printf '%s! Another tiktok-cloud comes first in PATH: %s%s\n' "$C_R" "$FOUND" "$C_0"
  printf '  Delete it so the new one is used:  rm %s\n' "$FOUND"
fi

printf '%s✔ Installed%s %s\n' "$C_G" "$C_0" "${REMOTE_VERSION:+($REMOTE_VERSION)}"

if [ -d "$SRC_DIR/.git" ] && [ "$(basename "$SRC_DIR")" = "tiktok-cloud-cli" ]; then
  cd "$HOME" 2>/dev/null && rm -rf "$SRC_DIR" 2>/dev/null
fi

printf '\n%s✔ Done!%s Run:  %stiktok-cloud%s\n' "$C_G" "$C_0" "$C_B" "$C_0"
printf 'Help: tiktok-cloud --help   |   Uninstall: tiktok-cloud --remove\n'
printf 'If "command not found" appears, run: exec $SHELL\n\n'
