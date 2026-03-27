# claude-good-boy

**Shared Claude Code rules that install in one command and update themselves.**

---

## What it is

This is a curated collection of coding rules for [Claude Code](https://claude.ai/code) (Anthropic's AI coding assistant), organized by stack and category. The rules get automatically loaded into every Claude Code session, giving the AI consistent, opinionated guidance across all your projects.

When cloned to `~/.claude/rules/shared/`, Claude Code discovers and applies the rules automatically. A SessionStart hook keeps the repo up to date on every session, so you always get the latest improvements without lifting a finger.

---

## Setup

One command installs everything:

```bash
bash <(curl -s https://raw.githubusercontent.com/vado-consulting/claude-good-boy/main/setup.sh)
```

This clones the repo to `~/.claude/rules/shared/` and registers a SessionStart hook that runs `git pull` at the start of every Claude Code session.

---

## How it works

**Auto-discovery**
Claude Code recursively scans `~/.claude/rules/` for all `.md` files and loads them as context at the start of every session. No configuration needed — drop a file in the directory, and it's active.

**Self-updating via SessionStart hook**
The setup script registers a hook in `~/.claude/settings.json` that runs `git pull` inside `~/.claude/rules/shared/` whenever a Claude Code session starts. You always have the latest rules without any manual updates.

**Path-scoped rules**
Rules that include a `paths:` frontmatter key only activate when you're working on files matching those patterns. For example, the Angular rules only load when Claude Code is editing files in a frontend directory — they don't add noise to a pure backend session.

---

## Available rule sets

| Category | File | Applies to |
|----------|------|------------|
| Git | `rules/general/git.md` | All projects |
| Java + Spring Boot | `rules/backend/java-spring.md` | `**/*.java` files |
| Angular + PrimeNG | `rules/frontend/angular.md` | Frontend files |
| Jenkins CLI | `rules/tools/jenkins.md` | All projects |

---

## Personal overrides

Files placed directly in `~/.claude/rules/` (outside `shared/`) are your personal rules. They load alongside the shared rules and are never touched by updates to this repo.

For example, create `~/.claude/rules/my-preferences.md` to add your own conventions, override anything in the shared rules, or add rules for tools your team doesn't use.

```
~/.claude/rules/
├── shared/                  ← this repo (auto-updated)
│   ├── rules/general/
│   ├── rules/backend/
│   └── ...
└── my-preferences.md        ← your personal rules (untouched)
```

---

## Project-specific rules

Rules for a specific project go in `.claude/rules/` inside the project repository. Commit them to git so the entire team benefits automatically — every developer on the project gets the same Claude Code behaviour without any setup.

```
your-project/
└── .claude/
    └── rules/
        └── architecture.md   ← project-specific rules, checked into git
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

PRs are welcome for new stacks, frameworks, and tools. If you've written rules that made Claude Code noticeably better in your workflow, share them here.

---

## Uninstall

```bash
rm -rf ~/.claude/rules/shared
```

Then open `~/.claude/settings.json` and remove the entry from `hooks.SessionStart` whose `command` contains `claude-good-boy` or `rules/shared`.
