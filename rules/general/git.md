# Git Conventions

## Authorship — MANDATORY

**Never add `Co-Authored-By` lines or any AI/tool attribution to commits.** The only author on a commit is the local git user — no exceptions.

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

- Subject line: max 50 characters, lowercase, imperative mood, no period
- Body (optional): wrap at 72 chars, explain *why* not *what* — the diff shows what
- Breaking changes: add `!` after type (`feat!:`) or `BREAKING CHANGE:` in footer

```
✅ feat(auth): add OAuth2 login with Google
✅ fix(api): return 404 instead of 500 when user not found
✅ refactor(order): extract payment logic into PaymentService

❌ fixed bug              — no type, vague
❌ feat: Added the thing. — past tense, capital, period
❌ fix: lots of changes   — too vague, split it
❌ WIP                    — never commit WIP to shared branches
```

## Atomic Commits

One commit = one logical change. The codebase must be in a working state after every commit.

- Never mix concerns — formatting, feature work, and refactors are separate commits
- If your commit message needs "and" in it, split it
- Use `git add -p` to stage only the relevant changes

## Branch Naming

Format: `<type>/<ticket-or-short-description>` — lowercase, hyphens only, include ticket when one exists.

```
✅ feat/user-authentication
✅ fix/VAD-123-login-redirect-loop
❌ my-branch    ❌ new_feature_login_thing_v2_FINAL
```

## Force Push — MANDATORY

**Never force-push on any branch.** `--force`, `--force-with-lease`, and `-f` are all forbidden.

Use `git revert` to undo changes already on the remote — never rewrite pushed history.

## Merging and Rebasing

- **Merge**: integrating finished branches, preserving history, or working on shared branches
- **Rebase**: cleaning up local commits before a PR, or syncing with main — **only on unpushed or private branches**

```bash
git fetch origin && git rebase origin/main   # sync feature branch with main
git rebase -i HEAD~3                          # clean up before opening PR
```

| Rebase command | Effect |
|----------------|--------|
| `pick` | Keep as-is |
| `reword` | Edit message |
| `squash` | Merge into previous, edit combined message |
| `fixup` | Merge into previous, discard message |
| `drop` | Delete commit |

**Golden rule:** Never rebase shared/public branches — it rewrites SHAs and breaks everyone else's history.

## Pull Requests

- Title follows conventional commit format: `feat(scope): description`
- Keep PRs small and focused — one concern per PR; aim for < 400 lines
- Squash-merge feature branches into main; delete branch after merging
- Self-review your diff before requesting review

```
## What
## Why
## How to test
```

## Tagging and Releases

Semantic Versioning: `MAJOR.MINOR.PATCH` (breaking / new feature / bug fix)

```bash
git tag -a v1.2.0 -m "release: v1.2.0" && git push origin v1.2.0
```

Always use annotated tags for releases. Never move or delete a released tag.

## Security — MANDATORY

- **Never commit secrets** — API keys, passwords, tokens, `.env` files — git history is permanent
- Add `.env`, `*.pem`, `*secret*`, `*credential*` to `.gitignore` before the first commit
- If a secret is accidentally committed: rotate it immediately, then scrub with `git filter-repo`
- Store secrets in a secrets manager (Vault, AWS Secrets Manager, GitHub Actions Secrets)

## .gitignore

- Commit `.gitignore` in the initial commit — before any other files
- Ignore: secrets, `node_modules/`, build artifacts, OS files (`.DS_Store`, `Thumbs.db`), editor dirs (`.idea/`, `.vscode/`)
- Personal preferences (OS/editor files) go in `~/.gitignore_global` — don't pollute the project `.gitignore`

## Cherry-Pick

Use **only for hotfixes** that must land on multiple branches — not a substitute for merge or rebase.

```bash
git cherry-pick abc1234 -x   # -x records the origin commit in the message
```

## Stashing

Use for **short-term context switches** only — use a branch for anything longer.

- Always add a message: `git stash push -m "wip: login form validation"`
- Regularly clean up: `git stash drop stash@{0}` or `git stash clear`

## Large Files

Use **Git LFS** for large assets (images, video, audio, binaries) — never commit them directly.

```bash
git lfs track "*.psd" && git add .gitattributes
```

## Collaboration Etiquette

- Pull before you push — always fetch/pull latest before starting work
- Keep branches short-lived — long-lived branches diverge and become painful to merge
- Never commit directly to main — always use a branch + PR
