#!/usr/bin/env bash
# claude-good-boy — Flyway-style migration runner
# Reads .migration-version (default 0), runs any migrations/NNN-*.sh where NNN > current.
# Updates .migration-version after each successful migration. Stops on first failure.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
MIGRATIONS_DIR="$REPO_DIR/migrations"
VERSION_FILE="$REPO_DIR/.migration-version"

# Nothing to do if no migrations directory
[ -d "$MIGRATIONS_DIR" ] || exit 0

# Read current version (default 0)
current=0
if [ -f "$VERSION_FILE" ]; then
  current=$(cat "$VERSION_FILE" | tr -d '[:space:]')
fi

# Find and sort migration scripts
for script in $(find "$MIGRATIONS_DIR" -maxdepth 1 -name '*.sh' | sort); do
  filename=$(basename "$script")
  # Extract leading number (e.g. "001" from "001-initial-setup.sh")
  num=$(echo "$filename" | grep -oE '^[0-9]+')
  if [ -z "$num" ]; then
    continue
  fi
  # Remove leading zeros for numeric comparison
  num_int=$((10#$num))
  if [ "$num_int" -gt "$current" ]; then
    echo "claude-good-boy: running migration $filename"
    if bash "$script"; then
      echo "$num_int" > "$VERSION_FILE"
      current=$num_int
    else
      echo "claude-good-boy: migration $filename failed — stopping" >&2
      exit 1
    fi
  fi
done
