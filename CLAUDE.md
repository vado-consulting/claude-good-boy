# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of Claude Code rules and skills that install to `~/.claude/claude-good-boy/` and self-update via a SessionStart hook. Rules are copied to `~/.claude/rules/shared/` and skills to `~/.claude/skills/shared/` on every session start.

## Directory structure

| Directory | Purpose |
|-----------|---------|
| `rules/general/` | Universal rules — load in every session |
| `rules/backend/` | Server-side language/framework rules |
| `rules/frontend/` | Client-side framework rules |
| `rules/tools/` | CLI tools and dev tooling rules |
| `skills/` | Shared slash commands (copied to `~/.claude/skills/shared/`) |
| `migrations/` | Numbered one-time migration scripts (Flyway-style) |

## Rule file conventions

Each rule file is a Markdown file in `rules/`.

**With `paths:` frontmatter** — rule only loads when editing files matching those globs:

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

## Adding skills

Place a `SKILL.md` file in `skills/<skill-name>/SKILL.md`. It will be synced to `~/.claude/skills/shared/<skill-name>/SKILL.md` and discoverable as a slash command.

## Adding migrations

Create a numbered bash script in `migrations/`, e.g. `migrations/002-add-permissions.sh`. The migration runner (`migrate.sh`) executes scripts in numeric order and tracks the last applied version in `.migration-version` (gitignored). Migrations run once per machine — use them for one-time infrastructure changes like updating hooks or settings.

## Key scripts

| Script | When it runs | Purpose |
|--------|-------------|---------|
| `setup.sh` | Once (manual install) | Clones repo, runs migrations + sync |
| `sync.sh` | Every session (via hook) | Wipe + copy rules and skills to discovery paths |
| `migrate.sh` | Every session (via hook) | Run any new numbered migration scripts |

## Testing changes locally

1. Edit files in `~/.claude/claude-good-boy/`
2. Run `bash sync.sh` to push changes to the discovery paths
3. Start a new Claude Code session — rules/skills should appear

## PR conventions

- One stack per PR
- Title format: `feat: add <stack> rules`
- Hand-written rules only — no AI-generated boilerplate
