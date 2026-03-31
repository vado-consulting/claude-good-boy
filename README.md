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
