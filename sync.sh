#!/usr/bin/env bash
# claude-good-boy — sync rules and skills to Claude Code discovery paths
# Called by the SessionStart hook after git pull.
# Wipes and replaces target directories to handle additions AND removals cleanly.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_TARGET="$HOME/.claude/rules/shared"
SKILLS_TARGET="$HOME/.claude/skills/shared"

# ── Sync rules ──────────────────────────────────────────────────────────────
if [ -d "$REPO_DIR/rules" ]; then
  rm -rf "$RULES_TARGET"
  mkdir -p "$(dirname "$RULES_TARGET")"
  cp -r "$REPO_DIR/rules" "$RULES_TARGET"
fi

# ── Sync skills ─────────────────────────────────────────────────────────────
if [ -d "$REPO_DIR/skills" ]; then
  rm -rf "$SKILLS_TARGET"
  mkdir -p "$(dirname "$SKILLS_TARGET")"
  cp -r "$REPO_DIR/skills" "$SKILLS_TARGET"
fi
