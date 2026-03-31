# Sync & Migration System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the current git-clone-into-rules-dir approach with a proper repo clone at `~/.claude/claude-good-boy/` plus a `sync.sh` (every-session copy of rules/skills) and `migrate.sh` (Flyway-style one-time numbered migrations). The team never has to run manual actions again — infrastructure changes propagate automatically via migrations.

**Architecture:** Repo clones to `~/.claude/claude-good-boy/`. On every SessionStart: `git pull` → `migrate.sh` (run any new numbered migrations) → `sync.sh` (wipe + copy `rules/` → `~/.claude/rules/shared/`, `skills/` → `~/.claude/skills/shared/`). First-time install via `setup.sh` does the clone + initial run. Migration state tracked in `~/.claude/claude-good-boy/.migration-version` (gitignored).

**Tech Stack:** Bash (no Python dependency), JSON manipulation via `python3` only in migrations that edit `settings.json` (existing pattern).

---

## Current State

- Repo clones directly to `~/.claude/rules/shared/` (repo root = rules discovery dir)
- `setup.sh` clones the repo and injects a SessionStart hook via python3
- SessionStart hook: `cd "$HOME/.claude/rules/shared" && git pull --ff-only 2>/dev/null || true`
- No skills support, no migration system

## Target State

```
~/.claude/
├── claude-good-boy/              ← repo clone (git-managed)
│   ├── rules/                    ← source of truth for rules
│   ├── skills/                   ← source of truth for skills
│   ├── migrations/               ← numbered one-time scripts
│   ├── migrate.sh                ← migration runner
│   ├── sync.sh                   ← every-session file sync
│   └── setup.sh                  ← first-time installer
├── rules/
│   └── shared/                   ← copy of claude-good-boy/rules/ (refreshed every session)
└── skills/
    └── shared/                   ← copy of claude-good-boy/skills/ (refreshed every session)
```

SessionStart hook becomes:
```bash
cd "$HOME/.claude/claude-good-boy" && git pull --ff-only 2>/dev/null; bash sync.sh; bash migrate.sh || true
```

---

### Task 1: Create `sync.sh`

**Files:**
- Create: `sync.sh`

**Step 1: Write `sync.sh`**

```bash
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
```

**Step 2: Commit**

```bash
git add sync.sh
git commit -m "feat: add sync.sh for rules and skills file sync"
```

---

### Task 2: Create `migrate.sh`

**Files:**
- Create: `migrate.sh`

**Step 1: Write `migrate.sh`**

```bash
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
```

**Step 2: Add `.migration-version` to `.gitignore`**

Append to `.gitignore`:
```
.migration-version
```

**Step 3: Commit**

```bash
git add migrate.sh .gitignore
git commit -m "feat: add migrate.sh flyway-style migration runner"
```

---

### Task 3: Create migration 001 — inject new SessionStart hook

This migration replaces the old hook (which pointed at `~/.claude/rules/shared/`) with the new one (which points at `~/.claude/claude-good-boy/` and runs sync + migrate).

**Files:**
- Create: `migrations/001-update-session-hook.sh`

**Step 1: Write the migration script**

```bash
#!/usr/bin/env bash
# Migration 001: Update SessionStart hook to use new repo location + sync + migrate
#
# Old hook: cd "$HOME/.claude/rules/shared" && git pull --ff-only 2>/dev/null || true
# New hook: cd "$HOME/.claude/claude-good-boy" && git pull --ff-only 2>/dev/null; bash sync.sh; bash migrate.sh || true

set -e

SETTINGS_FILE="$HOME/.claude/settings.json"

if ! command -v python3 &>/dev/null; then
  echo "  ⚠ python3 not found — cannot update settings.json" >&2
  exit 1
fi

python3 - <<'PYEOF'
import json, os

settings_file = os.path.expanduser("~/.claude/settings.json")
old_hook = 'cd "$HOME/.claude/rules/shared" && git pull --ff-only 2>/dev/null || true'
new_hook = 'cd "$HOME/.claude/claude-good-boy" && git pull --ff-only 2>/dev/null; bash sync.sh; bash migrate.sh || true'

settings = {}
if os.path.exists(settings_file):
    with open(settings_file) as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            pass

settings.setdefault("hooks", {})
settings["hooks"].setdefault("SessionStart", [])

# Remove old hook entries that reference rules/shared
new_entries = []
for entry in settings["hooks"]["SessionStart"]:
    hooks = entry.get("hooks", [])
    filtered = [h for h in hooks if "rules/shared" not in h.get("command", "")]
    if filtered:
        entry["hooks"] = filtered
        new_entries.append(entry)
settings["hooks"]["SessionStart"] = new_entries

# Check if new hook already exists
existing_commands = [
    h.get("command", "")
    for entry in settings["hooks"]["SessionStart"]
    for h in entry.get("hooks", [])
]

if new_hook not in existing_commands:
    settings["hooks"]["SessionStart"].append({
        "hooks": [{
            "type": "command",
            "command": new_hook,
            "statusMessage": "Syncing claude-good-boy...",
            "async": True
        }]
    })

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)

print("  → SessionStart hook updated")
PYEOF
```

**Step 2: Commit**

```bash
git add migrations/001-update-session-hook.sh
git commit -m "feat: add migration 001 to update session hook"
```

---

### Task 4: Rewrite `setup.sh` for new architecture

The new setup.sh clones to `~/.claude/claude-good-boy/`, runs `migrate.sh`, then runs `sync.sh`. It also handles the migration from old installs (repo at `~/.claude/rules/shared/` with `.git` directory).

**Files:**
- Modify: `setup.sh`

**Step 1: Rewrite `setup.sh`**

```bash
#!/usr/bin/env bash
# claude-good-boy — shared Claude Code rules & skills installer
# Usage: bash <(curl -s https://raw.githubusercontent.com/vado-consulting/claude-good-boy/main/setup.sh)
#
# What this does:
#   1. Clones the claude-good-boy repo to ~/.claude/claude-good-boy/
#      (or pulls the latest if already cloned)
#   2. Runs migrate.sh to apply any pending one-time migrations
#      (e.g. injecting the SessionStart hook into settings.json)
#   3. Runs sync.sh to copy rules and skills into Claude Code's discovery paths
#
# Idempotent: safe to run multiple times.

set -e

REPO_URL="https://github.com/vado-consulting/claude-good-boy"
REPO_DIR="$HOME/.claude/claude-good-boy"
OLD_DIR="$HOME/.claude/rules/shared"

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

# ── 2. Run migrations ──────────────────────────────────────────────────────
echo "→ Running migrations..."
bash "$REPO_DIR/migrate.sh"

# ── 3. Sync rules and skills ───────────────────────────────────────────────
echo "→ Syncing rules and skills..."
bash "$REPO_DIR/sync.sh"

echo ""
echo "✓ Done! claude-good-boy rules and skills are ready."
echo ""
echo "  Rules and skills sync automatically on every Claude Code session start."
echo "  Infrastructure changes apply automatically via migrations."
echo ""
echo "  Personal overrides: add .md files to ~/.claude/rules/ (outside shared/)"
echo "  Uninstall:          rm -rf ~/.claude/claude-good-boy ~/.claude/rules/shared ~/.claude/skills/shared"
echo "──────────────────────────────────────"
```

**Step 2: Commit**

```bash
git add setup.sh
git commit -m "feat: rewrite setup.sh for new repo location and sync/migrate architecture"
```

---

### Task 5: Create empty `skills/` directory

The skills directory needs to exist in the repo so `sync.sh` can copy it. Start with a `.gitkeep`.

**Files:**
- Create: `skills/.gitkeep`

**Step 1: Create the directory**

```bash
mkdir -p skills
touch skills/.gitkeep
```

**Step 2: Commit**

```bash
git add skills/.gitkeep
git commit -m "chore: add empty skills directory"
```

---

### Task 6: Update `CLAUDE.md`, `README.md`, and `CONTRIBUTING.md`

Update documentation to reflect the new architecture: repo location, sync.sh, migrate.sh, skills support.

**Files:**
- Modify: `CLAUDE.md`
- Modify: `README.md`
- Modify: `CONTRIBUTING.md`

**Step 1: Update `CLAUDE.md`**

Replace the entire contents with:

```markdown
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
```

**Step 2: Update `README.md`**

Replace the entire contents with:

```markdown
---
paths:
  - "**/.do-not-load"
---

# claude-good-boy

**Shared Claude Code rules and skills that install in one command and update themselves.**

---

## What it is

A curated collection of coding rules and reusable skills for [Claude Code](https://claude.ai/code) (Anthropic's AI coding assistant), organized by stack and category. Rules and skills sync automatically to Claude Code's discovery paths on every session start.

---

## Setup

One command installs everything:

```bash
bash <(curl -s https://raw.githubusercontent.com/vado-consulting/claude-good-boy/main/setup.sh)
```

This:
1. Clones the repo to `~/.claude/claude-good-boy/`
2. Runs pending migrations (e.g. registers the SessionStart hook)
3. Syncs rules to `~/.claude/rules/shared/` and skills to `~/.claude/skills/shared/`

---

## How it works

**Self-updating**
A SessionStart hook runs `git pull` → `sync.sh` → `migrate.sh` at the start of every Claude Code session. You always have the latest rules, skills, and infrastructure changes without any manual updates.

**Rules auto-discovery**
Claude Code recursively scans `~/.claude/rules/` for `.md` files and loads them as context. No configuration needed.

**Skills auto-discovery**
Claude Code discovers skills from `~/.claude/skills/`. Each skill is a `SKILL.md` file in a named subdirectory, invocable as a slash command.

**Path-scoped rules**
Rules with a `paths:` frontmatter key only activate when you're working on files matching those patterns.

**Zero-maintenance migrations**
Infrastructure changes (hook updates, new settings) are delivered as numbered migration scripts. They run automatically — your team never has to re-run setup or manually edit settings.

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

## Personal overrides

Files placed directly in `~/.claude/rules/` (outside `shared/`) are your personal rules. They load alongside the shared rules and are never touched by updates to this repo.

```
~/.claude/
├── claude-good-boy/             ← repo clone (auto-updated)
│   ├── rules/
│   ├── skills/
│   └── migrations/
├── rules/
│   ├── shared/                  ← synced copy of rules (auto-refreshed)
│   └── my-preferences.md       ← your personal rules (untouched)
└── skills/
    └── shared/                  ← synced copy of skills (auto-refreshed)
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Uninstall

```bash
rm -rf ~/.claude/claude-good-boy ~/.claude/rules/shared ~/.claude/skills/shared
```

Then open `~/.claude/settings.json` and remove the entry from `hooks.SessionStart` whose `command` contains `claude-good-boy`.
```

**Step 3: Commit**

```bash
git add CLAUDE.md README.md
git commit -m "docs: update CLAUDE.md and README.md for new architecture"
```

---

### Task 7: Test end-to-end locally

**Step 1: Run sync.sh manually and verify it copies rules**

```bash
cd ~/.claude/claude-good-boy && bash sync.sh
ls ~/.claude/rules/shared/general/
ls ~/.claude/skills/shared/
```

Expected: `git.md` listed under rules, `.gitkeep` under skills.

**Step 2: Run migrate.sh and verify it applies migration 001**

```bash
bash migrate.sh
cat .migration-version
cat ~/.claude/settings.json | python3 -m json.tool
```

Expected: `.migration-version` contains `1`. `settings.json` has the new hook command referencing `claude-good-boy`.

**Step 3: Verify the old hook was removed**

Check that `settings.json` no longer has a hook with `rules/shared` in the command.

**Step 4: Commit any final fixes, then push**

```bash
git push origin master
```
