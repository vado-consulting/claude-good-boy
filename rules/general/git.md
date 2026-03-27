# Git Conventions

## Commit Messages — Conventional Commits

Format: `<type>(<scope>): <description>`

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Maintenance, deps, config |
| `refactor` | Refactoring without behavior change |
| `docs` | Documentation only |
| `test` | Adding or fixing tests |
| `perf` | Performance improvement |
| `ci` | CI/CD changes |

### Rules
- Description is lowercase, imperative mood, no period
- Scope is optional but encouraged for larger codebases
- Body (optional): explain *why*, not *what* — the diff shows what
- Breaking changes: add `!` after type or `BREAKING CHANGE:` in footer

### Good examples
```
feat(auth): add OAuth2 login with Google
fix(api): return 404 instead of 500 when user not found
chore(deps): upgrade Spring Boot to 3.5.1
refactor(order): extract payment logic into PaymentService
docs: add setup instructions to README
test(user): add edge case for duplicate email registration
```

### Bad examples
```
❌ fixed bug              — no type, vague
❌ WIP                    — never commit WIP to shared branches
❌ feat: Added the thing. — past tense, capital, period
❌ fix: lots of changes   — too vague, should be split into multiple commits
❌ HOTFIX URGENT!!!       — no type, shouting
```

## Branch Naming

Format: `<type>/<ticket-or-short-description>`

### Good examples
```
feat/user-authentication
fix/VAD-123-login-redirect-loop
chore/upgrade-angular-19
refactor/extract-payment-service
```

### Bad examples
```
❌ my-branch
❌ fix
❌ johns-work-march
```

## Rules — MANDATORY

- **Never force-push to `main` or `master`**
- **Never commit secrets**, API keys, passwords, or `.env` files
- **Never add "Co-Authored-By: Claude"** lines — commits are yours
- **Never use `--no-verify`** to skip hooks unless explicitly instructed
- **Never commit directly to `main`** — always use a branch + PR
- **Keep commits atomic** — one logical change per commit
- **Write commit messages in English**

## Pull Requests

- Title follows the same conventional commit format as commits
- Link the related ticket in the description
- Keep PRs small and focused — one concern per PR
- Squash-merge feature branches to keep history clean
- Delete the branch after merging
---
