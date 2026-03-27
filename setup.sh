#!/usr/bin/env bash
# claude-good-boy — shared Claude Code rules installer
# Usage: bash <(curl -s https://raw.githubusercontent.com/vado-consulting/claude-good-boy/main/setup.sh)
#
# What this does:
#   1. Clones the claude-good-boy rules repo to ~/.claude/rules/shared/
#      (or pulls the latest if already cloned)
#   2. Injects a SessionStart hook into ~/.claude/settings.json
#      so rules auto-update on every Claude Code session start
#
# Idempotent: safe to run multiple times.

set -e

REPO_URL="https://github.com/vado-consulting/claude-good-boy"
RULES_DIR="$HOME/.claude/rules/shared"
SETTINGS_FILE="$HOME/.claude/settings.json"
HOOK_COMMAND='cd "$HOME/.claude/rules/shared" && git pull --ff-only 2>/dev/null || true'

echo "🐶 claude-good-boy setup"
echo "──────────────────────────────────────"

# ── 1. Clone or update the rules repo ────────────────────────────────────────
if [ -d "$RULES_DIR/.git" ]; then
  echo "→ Updating existing rules..."
  git -C "$RULES_DIR" pull --ff-only
else
  echo "→ Cloning rules into $RULES_DIR..."
  mkdir -p "$(dirname "$RULES_DIR")"
  git clone "$REPO_URL" "$RULES_DIR"
fi

# ── 2. Inject SessionStart hook into ~/.claude/settings.json ─────────────────
mkdir -p "$(dirname "$SETTINGS_FILE")"

if ! command -v python3 &>/dev/null; then
  echo ""
  echo "  ⚠ python3 not found — skipping hook installation."
  echo "  To finish setup manually, add this to ~/.claude/settings.json:"
  echo "    hooks > SessionStart > command:"
  echo "    cd \"\$HOME/.claude/rules/shared\" && git pull --ff-only 2>/dev/null || true"
  exit 0
fi

python3 - <<PYEOF
import json, os

settings_file = os.path.expanduser("~/.claude/settings.json")
hook_command = 'cd "\$HOME/.claude/rules/shared" && git pull --ff-only 2>/dev/null || true'

settings = {}
if os.path.exists(settings_file):
    with open(settings_file) as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            print("  Warning: could not parse existing settings.json — starting fresh")

settings.setdefault("hooks", {})
settings["hooks"].setdefault("SessionStart", [])

existing_commands = [
    h.get("command", "")
    for entry in settings["hooks"]["SessionStart"]
    for h in entry.get("hooks", [])
]

if hook_command in existing_commands:
    print("→ Auto-update hook already present — nothing to do.")
else:
    settings["hooks"]["SessionStart"].append({
        "hooks": [{
            "type": "command",
            "command": hook_command,
            "async": True,
            "statusMessage": "Updating shared rules..."
        }]
    })
    with open(settings_file, "w") as f:
        json.dump(settings, f, indent=2)
    print(f"→ Auto-update hook added to {settings_file}")
PYEOF

echo ""
echo "✓ Done! claude-good-boy rules are ready."
echo ""
echo "  Rules load automatically in every Claude Code session."
echo "  They update silently in the background on each session start."
echo ""
echo "  Personal overrides: add .md files to ~/.claude/rules/ (outside shared/)"
echo "  Uninstall:          rm -rf ~/.claude/rules/shared"
echo "──────────────────────────────────────"
