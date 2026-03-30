# Git Conventions

## Authorship — MANDATORY

**Never add `Co-Authored-By` lines or any AI/tool attribution to commits.** The only author is the local git user.

## Commit Messages — Conventional Commits

Format: `<type>(<scope>): <description>` — max 50 chars, lowercase, imperative mood, no period.

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Maintenance, deps, config |
| `refactor` | No behavior change |
| `docs` | Docs only |
| `test` | Tests |
| `perf` | Performance |
| `ci` | CI/CD |

Body (optional): wrap at 72 chars, explain *why* not *what*. Breaking changes: `feat!:` or `BREAKING CHANGE:` in footer.

## Atomic Commits

One commit = one logical change. Never mix concerns. If the message needs "and", split it.

## Branch Naming

`<type>/<ticket-or-short-description>` — lowercase, hyphens, include ticket if one exists.
e.g. `feat/user-authentication`, `fix/VAD-123-login-redirect`

## Force Push — MANDATORY

**Never force-push on any branch.** `--force`, `--force-with-lease`, and `-f` are all forbidden. Use `git revert` instead.

## Merging and Rebasing

- Squash-merge feature branches into main; delete branch after merging
- Rebase only on unpushed/private branches — never on shared branches

## Pull Requests

- Title: conventional commit format
- One concern per PR; aim for < 400 lines
- Template: `## What / ## Why / ## How to test`

## Security — MANDATORY

**Never commit secrets** — API keys, passwords, tokens, `.env` files. If accidentally committed: rotate immediately, scrub with `git filter-repo`.
