#!/usr/bin/env bash
# Migration 001: Update SessionStart hook to use new repo location + sync + migrate
#
# Handles the UPGRADE case: replaces the old rules/shared hook command with the
# new claude-good-boy hook. Fresh installs are handled by setup.sh directly.

set -e

SETTINGS_FILE="${HOME}/.claude/settings.json"

[ -f "$SETTINGS_FILE" ] || exit 0

# Already migrated
if grep -qF "claude-good-boy" "$SETTINGS_FILE"; then
  echo "  → SessionStart hook already up to date"
  exit 0
fi

# No old hook to replace — nothing for this migration to do
if ! grep -qF "rules/shared" "$SETTINGS_FILE"; then
  exit 0
fi

# Replace the command value (swap rules/shared path and add sync+migrate)
sed -i 's#rules/shared\\" && git pull --ff-only 2>/dev/null || true#claude-good-boy\\" \&\& git pull --ff-only 2>/dev/null; bash sync.sh; bash migrate.sh || true#g' "$SETTINGS_FILE"

# Replace the status message
sed -i 's#Updating shared rules\.\.\.#Syncing claude-good-boy...#g' "$SETTINGS_FILE"

echo "  → SessionStart hook updated"
