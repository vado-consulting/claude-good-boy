#!/usr/bin/env bash
# claude-good-boy — sync rules and skills to Claude Code discovery paths
# Called by the SessionStart hook after git pull.
# Wipes and replaces target directories to handle additions AND removals cleanly.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_TARGET="$HOME/.claude/rules/shared"

# ── Sync rules ──────────────────────────────────────────────────────────────
if [ -d "$REPO_DIR/rules" ]; then
  rm -rf "$RULES_TARGET"
  mkdir -p "$(dirname "$RULES_TARGET")"
  cp -r "$REPO_DIR/rules" "$RULES_TARGET"
fi

# ── Sync skills ─────────────────────────────────────────────────────────────
# Skills must be one level deep in ~/.claude/skills/ to be discovered.
# We prefix shared skills with "shared--" so they can be cleanly removed
# without touching personal skills.
SKILLS_DIR="$HOME/.claude/skills"
SKILLS_PREFIX="shared--"

if [ -d "$REPO_DIR/skills" ]; then
  mkdir -p "$SKILLS_DIR"
  # Remove previously synced shared skills
  find "$SKILLS_DIR" -maxdepth 1 -type d -name "${SKILLS_PREFIX}*" -exec rm -rf {} +
  # Copy each skill with the prefix
  for skill_dir in "$REPO_DIR/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    cp -r "$skill_dir" "$SKILLS_DIR/${SKILLS_PREFIX}${skill_name}"
  done
fi
