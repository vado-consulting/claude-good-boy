---
paths:
  - "**/.do-not-load"
---

# Contributing to claude-good-boy

Thanks for your interest in contributing! This repo is meant to grow into a broad library of Claude Code rules covering as many stacks as possible, and contributions of new rule files are very welcome. If you have hard-won conventions for a language, framework, or tool that you'd like to share, this is the right place.

---

## Repo structure

```
claude-good-boy/
├── rules/               # Rule markdown files (synced to ~/.claude/rules/shared/)
│   ├── general/         # Universal rules (git, code style, etc.)
│   ├── backend/         # Backend language/framework rules
│   ├── frontend/        # Frontend framework rules
│   └── tools/           # CLI tools and dev tooling
├── skills/              # Shared slash commands (synced to ~/.claude/skills/shared--*/)
├── migrations/          # Numbered one-time migration scripts
├── setup.sh             # First-time installer
├── sync.sh              # Every-session file sync
└── migrate.sh           # Migration runner
```

---

## Adding a new rule file

1. **Choose the right category folder** — pick the folder that best matches the rule's scope:
   - `general/` — applies regardless of stack (e.g. git commit conventions, code review etiquette)
   - `backend/` — server-side languages and frameworks (e.g. Java Spring, Python FastAPI, Go)
   - `frontend/` — client-side frameworks and tooling (e.g. Angular, React, Vue)
   - `tools/` — CLI tools and developer tooling (e.g. Docker, Terraform, GitHub Actions)

2. **Create a `.md` file** named after the stack, e.g. `rules/backend/python-fastapi.md`. Use lowercase kebab-case.

3. **Add YAML frontmatter** with `paths:` if the rule should only load for certain file types (see format below). Omit frontmatter if the rule is universal.

4. **Write the rules** following the format guidelines below.

5. **Open a PR** — one stack per PR, please.

---

## Frontmatter format

Use the `paths:` key to limit when a rule file loads:

```yaml
---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
```

**Rules WITHOUT `paths:`** load in every Claude Code session. Use this for universal rules such as git conventions or general code style that apply regardless of what files are open.

**Rules WITH `paths:`** only load when Claude Code is working on files that match the glob patterns. This is the right choice for language- or framework-specific rules — it keeps context lean and avoids irrelevant guidance.

---

## Rule file format

- Use clear markdown headers (`##`, `###`) to group related rules.
- Include **good and bad code examples** for any rule that is not immediately obvious. Seeing a concrete counterexample removes all ambiguity.
- Mark critical rules as **MANDATORY** in the header or inline (e.g. `## Constructor Injection — MANDATORY`). This signals to Claude that these rules cannot be bent.
- Keep rules actionable. Prefer "do X" or "never Y" over vague advice like "try to keep things clean".
- Use tables for reference information such as command lists, option comparisons, or status mappings — they are easier to scan than prose.

---

## Example rule file skeleton

```markdown
---
paths:
  - "**/*.py"
---

# Python Conventions

## Style

- Use type hints on all function signatures.
- Prefer dataclasses or Pydantic models over plain dicts for structured data.
- ...

## Imports — MANDATORY

- Standard library imports first, then third-party, then local. One blank line between each group.
- Never use wildcard imports (`from module import *`).

## Good vs Bad

\`\`\`python
# Good
def get_user(user_id: int) -> User:
    ...

# Bad — no type hints
def get_user(user_id):
    ...
\`\`\`
```

---

## PR guidelines

- **One stack per PR.** Mixing multiple unrelated stacks makes review harder.
- **Test locally.** Clone the repo, run `setup.sh`, open a project that matches your rule's `paths:`, and confirm the rules appear in Claude Code's context.
- **PR title format:** `feat: add <stack> rules` — for example, `feat: add Python + FastAPI rules` or `feat: add Terraform rules`.
- **No generated content.** Rules must be hand-written and reflect real team or project experience. AI-generated boilerplate that has never been tested in practice is not useful here.
