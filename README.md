# Claude Usage Indicator

A small GNOME top-bar (tray) app for Ubuntu that shows your Claude subscription
rate-limit usage — the same numbers as Claude Code's `/usage` command.

The top bar shows `12% · wk 34%` (5-hour session · weekly). The dropdown menu
shows all windows with reset times:

- 5-hour session window
- Weekly (all models), Weekly (Opus), Weekly (Sonnet)
- Extra usage credits (if enabled)

The icon turns amber at 70% and red at 90% of your worst limit.

## Install

```bash
git clone https://github.com/wolfgangrumpf/claude-usage-indicator.git
cd claude-usage-indicator
bash install.sh        # run as your own user, NOT with sudo
```

Installs per-user to `~/.local`, starts immediately, and autostarts on login.
System packages `python3-gi` and `gir1.2-ayatanaappindicator3-0.1` are
installed via apt if missing (the only sudo step).

## Requirements

- Ubuntu 20.04+ with GNOME (the stock "Ubuntu AppIndicators" extension, enabled by default)
- A Claude Pro/Max subscription, with Claude Code logged in at least once
  (`claude` → `/login` → "Claude account with subscription")

## How it works

Polls `https://api.anthropic.com/api/oauth/usage` every 3 minutes (the
community-tested safe interval; exponential backoff on 429). This is the
endpoint that powers Claude Code's `/usage`. The OAuth token is read from
`$CLAUDE_CODE_OAUTH_TOKEN`, `$CLAUDE_CONFIG_DIR/.credentials.json`,
`~/.claude/.credentials.json`, or `~/.config/claude/.credentials.json`.
Your token never leaves your machine except to Anthropic's API.

Access tokens expire hourly; Claude Code refreshes them whenever it runs —
if the indicator shows "Token expired", just open Claude Code.

## Troubleshooting

- **Ran it with sudo?** It would install to root's home (the installer
  refuses to run as root). Clean `/root/.local` and `/root/.config/autostart`,
  then re-run without sudo.
- **"No credentials"** — install Claude Code and log in with
  "Claude account with subscription", not a Console/API account.
- **Nothing in the top bar** — enable GNOME's AppIndicator extension:
  `gnome-extensions enable ubuntu-appindicators@ubuntu.com`
- **Python error about AppIndicator3** —
  `sudo apt install gir1.2-ayatanaappindicator3-0.1 python3-gi gir1.2-gtk-3.0`

## Uninstall

```bash
bash uninstall.sh
```

## Disclaimer

This uses an undocumented Anthropic endpoint (the one behind Claude Code's
`/usage`); it may change or break without notice. Not affiliated with
Anthropic. MIT licensed — see [LICENSE](LICENSE).
