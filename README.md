---
paths:
  - "**/.do-not-load"
---

# claude-good-boy

**Shared Claude Code rules and skills that install in one command and update themselves.**

---

## What it is

A curated collection of coding rules and reusable skills for [Claude Code](https://claude.ai/code) (Anthropic's AI coding assistant), organized by stack and category. Once installed, everything syncs automatically — rules, skills, and infrastructure changes — without anyone on the team lifting a finger.

---

## Setup

One command installs everything:

```bash
bash <(curl -s https://raw.githubusercontent.com/vado-consulting/claude-good-boy/main/setup.sh)
```

This:
1. Clones the repo to `~/.claude/claude-good-boy/`
2. Registers a SessionStart hook that keeps everything up to date
3. Runs any pending migrations
4. Syncs rules and skills to Claude Code's discovery paths

Re-running the command is safe — it's idempotent.

---

## How it works

Every time a Claude Code session starts, the SessionStart hook runs:

```
git pull  →  sync.sh  →  migrate.sh
```

| Step | What happens |
|------|-------------|
| `git pull` | Fetches the latest changes from the repo |
| `sync.sh` | Wipes and replaces `~/.claude/rules/shared/` and `~/.claude/skills/shared--*/` with fresh copies from the repo. Handles additions and removals cleanly. |
| `migrate.sh` | Checks `.migration-version` and runs any new numbered scripts from `migrations/`. One-time infrastructure changes go here. |

### Rules auto-discovery

Claude Code recursively scans `~/.claude/rules/` for `.md` files and loads them as context. Rules with a `paths:` frontmatter key only activate when you're working on files matching those patterns — keeping context lean.

### Skills auto-discovery

Claude Code discovers skills from `~/.claude/skills/`. Each skill is a `SKILL.md` file in a named subdirectory, invocable as a slash command.

### Zero-maintenance migrations

Infrastructure changes (hook updates, new settings, new directories to sync) are delivered as numbered migration scripts in `migrations/`. They run automatically after each `git pull` — your team never has to re-run setup or manually edit settings.

---

## Directory layout

### In the repo

```
claude-good-boy/
├── rules/                        # Rule markdown files
│   ├── general/                  # Universal — every session
│   ├── backend/                  # Server-side (Java, Spring Boot, ...)
│   ├── frontend/                 # Client-side (Angular, PrimeNG, ...)
│   └── tools/                    # CLI tools (Jenkins, Maven, npm, ...)
├── skills/                       # Shared slash commands
├── migrations/                   # Numbered one-time scripts
│   └── 001-update-session-hook.sh
├── setup.sh                      # First-time installer
├── sync.sh                       # Every-session file sync
└── migrate.sh                    # Migration runner
```

### On the developer's machine

```
~/.claude/
├── claude-good-boy/              # Git repo (source of truth, auto-updated)
│   ├── rules/
│   ├── skills/
│   ├── migrations/
│   ├── sync.sh
│   ├── migrate.sh
│   └── setup.sh
├── rules/
│   ├── shared/                   # Copy of rules (refreshed every session)
│   └── my-preferences.md         # Personal overrides (untouched)
└── skills/
    ├── shared--code-review/      # Synced skills (prefixed, refreshed every session)
    └── shared--deploy-check/     # Personal skills live here unprefixed
```

---

## Available rule sets

| Category | File | Applies to |
|----------|------|------------|
| Git | `rules/general/git.md` | All projects |
| Java + Spring Boot | `rules/backend/java-spring.md` | `**/*.java` files |
| Angular + PrimeNG | `rules/frontend/angular.md` | Frontend files |
| Jenkins CLI | `rules/tools/jenkins.md` | All projects |
| Maven | `rules/tools/maven.md` | `**/pom.xml` files |
| npm | `rules/tools/npm.md` | `**/package.json` files |

---

## Key scripts

| Script | Runs when | Purpose |
|--------|-----------|---------|
| `setup.sh` | Once (manual) | Clones repo, injects SessionStart hook, runs initial sync + migrate |
| `sync.sh` | Every session (automatic) | Syncs rules to `~/.claude/rules/shared/` and skills to `~/.claude/skills/shared--*/` |
| `migrate.sh` | Every session (automatic) | Runs any new `migrations/NNN-*.sh` scripts, tracks state in `.migration-version` |

---

## Personal overrides

Files placed directly in `~/.claude/rules/` (outside `shared/`) are your personal rules. They load alongside the shared rules and are never touched by sync.

---

## Adding rules

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide. The short version:

1. Add a `.md` file to the right `rules/` subfolder
2. Add `paths:` frontmatter if it's stack-specific
3. Open a PR — one stack per PR

## Adding skills

Place a `SKILL.md` in `skills/<skill-name>/SKILL.md`. It will be synced to `~/.claude/skills/shared--<skill-name>/` and discoverable as a slash command. The `shared--` prefix keeps shared skills separate from personal ones.

## Adding migrations

Create `migrations/NNN-description.sh` (e.g. `002-add-permissions.sh`). The runner executes scripts in numeric order and only runs each one once. Use migrations for one-time changes like updating hooks or settings.

---

## Uninstall

```bash
rm -rf ~/.claude/claude-good-boy ~/.claude/rules/shared ~/.claude/skills/shared--*
```

Then open `~/.claude/settings.json` and remove the entry from `hooks.SessionStart` whose `command` contains `claude-good-boy`.
