#!/usr/bin/env bash
set -euo pipefail
pkill -f "$HOME/.local/bin/claude-usage-indicator" 2>/dev/null || true
rm -f "$HOME/.local/bin/claude-usage-indicator" \
      "$HOME/.local/share/applications/claude-usage-indicator.desktop" \
      "$HOME/.config/autostart/claude-usage-indicator.desktop"
rm -rf "$HOME/.local/share/claude-usage-indicator"
echo "Claude Usage Indicator removed."
