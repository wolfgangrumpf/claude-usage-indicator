#!/usr/bin/env bash
# Installer for Claude Usage Indicator (per-user; run as yourself, NOT sudo)
set -euo pipefail
cd "$(dirname "$0")"

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this installer with sudo — it installs per-user."
    echo "Run: bash install.sh   (it will sudo internally only for apt)"
    exit 1
fi

BIN="$HOME/.local/bin"
SHARE="$HOME/.local/share/claude-usage-indicator"
APPS="$HOME/.local/share/applications"
AUTOSTART="$HOME/.config/autostart"

echo "==> Checking dependencies (python3-gi + AppIndicator bindings)…"
NEED=()
dpkg -s python3-gi >/dev/null 2>&1 || NEED+=(python3-gi)
dpkg -s gir1.2-gtk-3.0 >/dev/null 2>&1 || NEED+=(gir1.2-gtk-3.0)
if ! dpkg -s gir1.2-ayatanaappindicator3-0.1 >/dev/null 2>&1 && \
   ! dpkg -s gir1.2-appindicator3-0.1 >/dev/null 2>&1; then
    NEED+=(gir1.2-ayatanaappindicator3-0.1)
fi
if [ ${#NEED[@]} -gt 0 ]; then
    echo "    Installing: ${NEED[*]} (sudo required)"
    sudo apt-get install -y "${NEED[@]}"
fi

echo "==> Installing files…"
mkdir -p "$BIN" "$SHARE/icons" "$APPS" "$AUTOSTART"
install -m 755 claude-usage-indicator "$BIN/claude-usage-indicator"
install -m 644 icons/*.svg "$SHARE/icons/"

DESKTOP="[Desktop Entry]
Type=Application
Name=Claude Usage Indicator
Comment=Claude subscription usage in the top bar
Exec=$BIN/claude-usage-indicator
Icon=$SHARE/icons/claude-usage-ok.svg
Categories=Utility;
X-GNOME-Autostart-enabled=true"
echo "$DESKTOP" > "$APPS/claude-usage-indicator.desktop"
echo "$DESKTOP" > "$AUTOSTART/claude-usage-indicator.desktop"

if [ ! -f "$HOME/.claude/.credentials.json" ] && \
   [ ! -f "${CLAUDE_CONFIG_DIR:-/nonexistent}/.credentials.json" ] && \
   [ ! -f "$HOME/.config/claude/.credentials.json" ] && \
   [ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
    echo "!! Warning: no Claude Code credentials found. Log in once (run: claude)."
    echo "   The indicator will still install and will show usage once you do."
fi

echo "==> Done. Starting indicator…"
pkill -f "$BIN/claude-usage-indicator" 2>/dev/null || true
nohup "$BIN/claude-usage-indicator" >/dev/null 2>&1 &
echo "    It will also start automatically on login."
echo "    Uninstall with: bash uninstall.sh"
