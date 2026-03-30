# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of Claude Code rules that install to `~/.claude/rules/shared/` and self-update via a SessionStart hook (`git pull`). Rules are auto-discovered by Claude Code from that directory at session start.

## Rule file conventions

Each rule file is a Markdown file in one of these folders:

| Folder | Scope |
|--------|-------|
| `rules/general/` | Universal — loads in every session |
| `rules/backend/` | Server-side languages/frameworks |
| `rules/frontend/` | Client-side frameworks |
| `rules/tools/` | CLI tools and dev tooling |

**With `paths:` frontmatter** — rule only loads when Claude Code is editing files matching those globs:

```yaml
---
paths:
  - "**/*.java"
---
```

**Without frontmatter** — rule loads in every session regardless of files open.

## Adding or editing rules

- File names: lowercase kebab-case, e.g. `rules/backend/python-fastapi.md`
- Mark non-obvious, critical rules with **MANDATORY** in the header
- Always include concrete good/bad examples for non-obvious rules
- Use tables for reference information (command lists, option comparisons)
- Keep rules actionable: "do X" or "never Y", not vague advice

## Testing changes locally

1. The repo must be cloned at `~/.claude/rules/shared/`
2. Open a project whose files match the rule's `paths:` globs
3. Start a new Claude Code session — the rule should appear in the loaded context
4. For universal rules (no `paths:`), any new session will pick them up

## Setup script

`setup.sh` clones this repo to `~/.claude/rules/shared/` and injects a SessionStart hook into `~/.claude/settings.json` that runs `git pull --ff-only` on session start. It is idempotent.

## PR conventions

- One stack per PR
- Title format: `feat: add <stack> rules`
- Hand-written rules only — no AI-generated boilerplate
