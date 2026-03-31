#!/usr/bin/env bash
# claude-good-boy — shared Claude Code rules & skills installer
# Usage: bash <(curl -s https://raw.githubusercontent.com/vado-consulting/claude-good-boy/main/setup.sh)
#
# What this does:
#   1. Clones the claude-good-boy repo to ~/.claude/claude-good-boy/
#      (or pulls the latest if already cloned)
#   2. Ensures the SessionStart hook is registered in settings.json
#   3. Runs migrate.sh to apply any pending one-time migrations
#   4. Runs sync.sh to copy rules and skills into Claude Code's discovery paths
#
# Idempotent: safe to run multiple times.

set -e

REPO_URL="https://github.com/vado-consulting/claude-good-boy"
REPO_DIR="$HOME/.claude/claude-good-boy"
OLD_DIR="$HOME/.claude/rules/shared"
SETTINGS_FILE="$HOME/.claude/settings.json"
HOOK_CMD='cd "$HOME/.claude/claude-good-boy" && git pull --ff-only 2>/dev/null; bash sync.sh; bash migrate.sh || true'

echo "🐶 claude-good-boy setup"
echo "──────────────────────────────────────"

# ── 0. Migrate from old install location if needed ──────────────────────────
if [ -d "$OLD_DIR/.git" ] && [ ! -d "$REPO_DIR/.git" ]; then
  echo "→ Migrating from old location ($OLD_DIR)..."
  mkdir -p "$(dirname "$REPO_DIR")"
  mv "$OLD_DIR" "$REPO_DIR"
  echo "  Moved to $REPO_DIR"
fi

# ── 1. Clone or update the repo ────────────────────────────────────────────
if [ -d "$REPO_DIR/.git" ]; then
  echo "→ Updating existing repo..."
  git -C "$REPO_DIR" pull --ff-only
else
  echo "→ Cloning repo into $REPO_DIR..."
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR"
fi

# ── 2. Ensure SessionStart hook exists ──────────────────────────────────────
mkdir -p "$(dirname "$SETTINGS_FILE")"

if [ -f "$SETTINGS_FILE" ] && grep -qF "claude-good-boy" "$SETTINGS_FILE"; then
  echo "→ SessionStart hook already present"
else
  echo "→ Adding SessionStart hook..."
  if [ ! -f "$SETTINGS_FILE" ] || [ ! -s "$SETTINGS_FILE" ]; then
    # No settings file — write one from scratch
    cat > "$SETTINGS_FILE" <<'ENDJSON'
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cd \"$HOME/.claude/claude-good-boy\" && git pull --ff-only 2>/dev/null; bash sync.sh; bash migrate.sh || true",
            "statusMessage": "Syncing claude-good-boy...",
            "async": true
          }
        ]
      }
    ]
  }
}
ENDJSON
    echo "  Created $SETTINGS_FILE with hook"
  else
    # Settings file exists but doesn't have our hook — show manual instructions
    echo ""
    echo "  ⚠ settings.json exists but doesn't contain the claude-good-boy hook."
    echo "  Please add this to your ~/.claude/settings.json under hooks.SessionStart:"
    echo ""
    echo "  {"
    echo "    \"hooks\": [{"
    echo "      \"type\": \"command\","
    echo "      \"command\": \"cd \\\"\$HOME/.claude/claude-good-boy\\\" && git pull --ff-only 2>/dev/null; bash sync.sh; bash migrate.sh || true\","
    echo "      \"statusMessage\": \"Syncing claude-good-boy...\","
    echo "      \"async\": true"
    echo "    }]"
    echo "  }"
    echo ""
  fi
fi

# ── 3. Run migrations ──────────────────────────────────────────────────────
echo "→ Running migrations..."
bash "$REPO_DIR/migrate.sh"

# ── 4. Sync rules and skills ───────────────────────────────────────────────
echo "→ Syncing rules and skills..."
bash "$REPO_DIR/sync.sh"

echo ""
echo "✓ Done! claude-good-boy rules and skills are ready."
echo ""
echo "  Rules and skills sync automatically on every Claude Code session start."
echo "  Infrastructure changes apply automatically via migrations."
echo ""
echo "  Personal overrides: add .md files to ~/.claude/rules/ (outside shared/)"
echo "  Uninstall:          rm -rf ~/.claude/claude-good-boy ~/.claude/rules/shared ~/.claude/skills/shared--*"
echo "──────────────────────────────────────"
