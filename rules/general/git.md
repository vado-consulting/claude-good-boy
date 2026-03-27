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
- Subject line: max 50 characters, lowercase, imperative mood, no period
- Body (optional): wrap at 72 chars, explain *why* not *what* — the diff shows what
- Breaking changes: add `!` after type (`feat!:`) or `BREAKING CHANGE:` in footer
- Scope is optional but encouraged in larger codebases

### Good examples
```
feat(auth): add OAuth2 login with Google
fix(api): return 404 instead of 500 when user not found
chore(deps): upgrade Spring Boot to 3.5.1
refactor(order): extract payment logic into PaymentService
docs: add setup instructions to README
test(user): add edge case for duplicate email registration
feat!: drop support for Node 16
```

### Bad examples
```
❌ fixed bug              — no type, vague
❌ WIP                    — never commit WIP to shared branches
❌ feat: Added the thing. — past tense, capital, period
❌ fix: lots of changes   — too vague, should be split into multiple commits
❌ HOTFIX URGENT!!!       — no type, shouting
❌ misc                   — meaningless
❌ asdfgh                 — placeholder
```

---

## Atomic Commits

One commit = one logical change. The codebase must be in a working state after every commit.

- **Never mix concerns** — formatting fixes, feature work, and refactors are separate commits
- **Never commit broken code** — all tests must pass at every commit
- Use `git add -p` (interactive staging) to split unrelated changes into separate commits
- If your commit message needs "and" in it, split it

```
✅ fix(login): handle null response from auth service
✅ style(login): fix indentation in auth component

❌ fix(login): handle null response and fix indentation
```

---

## Branch Naming

Format: `<type>/<ticket-or-short-description>`

```
feat/user-authentication
fix/VAD-123-login-redirect-loop
chore/upgrade-angular-19
refactor/extract-payment-service
hotfix/critical-payment-null-pointer
docs/update-api-readme
```

### Rules
- Use lowercase and hyphens only — no spaces, underscores, or capitals
- Include the ticket number when one exists
- Keep it short and descriptive — conveys purpose at a glance

### Bad examples
```
❌ my-branch
❌ fix
❌ johns-work-march
❌ new_feature_login_thing_v2_FINAL
```

---

## Force Push — MANDATORY

- **Never force-push to any shared branch** — main, master, develop, release/*, hotfix/*
- **Never force-push to any branch others are working on**
- If you must rewrite history on your own feature branch: use `--force-with-lease` instead of `--force`

```bash
# Safe — refuses if someone else pushed in the meantime
git push --force-with-lease origin feat/my-feature

# Dangerous — never use on shared branches
git push --force origin main   ❌
```

`--force-with-lease` checks that the remote hasn't changed since your last fetch. It protects teammates from having their work overwritten.

---

## Merging and Rebasing

### When to merge
- Integrating a finished feature branch into main/develop
- Preserving exact history of what happened and when
- Working on a branch shared with others

### When to rebase
- Cleaning up your local feature branch before opening a PR
- Getting the latest changes from main onto your branch without a merge commit
- **Only rebase commits that have not been pushed**, or your own private branch

```bash
# Get latest main onto your feature branch cleanly
git fetch origin
git rebase origin/main

# Clean up your last 3 commits before PR
git rebase -i HEAD~3
```

### Interactive rebase commands
| Command | Effect |
|---------|--------|
| `pick` | Keep commit as-is |
| `reword` | Keep commit, edit message |
| `squash` | Merge into previous commit, edit combined message |
| `fixup` | Merge into previous commit, discard this message |
| `drop` | Delete the commit entirely |

### Golden rule
**Never rebase shared/public branches.** Rebase rewrites commit SHAs — anyone else based on those commits will have a broken history.

---

## Pull Requests

- Title follows conventional commit format: `feat(scope): description`
- Link the related ticket in the description
- Keep PRs **small and focused** — one concern per PR; aim for < 400 lines changed
- Self-review your own diff before requesting review — catch obvious issues yourself
- Merge strategy: **squash-merge** feature branches to keep main history clean
- Delete the branch after merging

### PR description template
```
## What
Brief description of the change.

## Why
Why this change is needed (link to ticket if applicable).

## How to test
Steps to verify the change works.
```

---

## History Hygiene

### Amend the last commit (only if not pushed)
```bash
# Fix the commit message
git commit --amend -m "feat(auth): add Google OAuth2 login"

# Add a forgotten file
git add forgotten-file.ts
git commit --amend --no-edit
```

### Squash commits before merging
Use `git rebase -i` to squash WIP commits into clean logical units before opening a PR. The PR should tell a clean story, not expose every `fix typo` and `wip` commit.

### Never rewrite pushed history
Once commits are on a shared remote branch, treat them as immutable. Rewriting pushed history breaks everyone else's local copy.

---

## Tagging and Releases

Use **Semantic Versioning**: `MAJOR.MINOR.PATCH`

| Part | When to increment |
|------|------------------|
| MAJOR | Breaking change |
| MINOR | New backward-compatible feature |
| PATCH | Bug fix |

```bash
# Create an annotated tag (preferred for releases)
git tag -a v1.2.0 -m "release: v1.2.0"
git push origin v1.2.0

# Lightweight tag (for local bookmarks only)
git tag v1.2.0-rc1
```

Always use **annotated tags** for releases — they store author, date, and message. Never move or delete a released tag.

---

## Security — MANDATORY

- **Never commit secrets** — API keys, passwords, tokens, certificates, `.env` files
- **Never commit credentials** even temporarily — git history is permanent and public
- Add `.env`, `*.pem`, `*secret*`, `*credential*` to `.gitignore` before the first commit
- If a secret is accidentally committed: rotate it immediately, then use `git filter-repo` to scrub history
- Use pre-commit hooks (gitleaks, detect-secrets) to catch leaks before they happen
- Store secrets in a secrets manager (HashiCorp Vault, AWS Secrets Manager, GitHub Actions Secrets)

---

## .gitignore

- Commit `.gitignore` in the initial commit — before any other files
- Ignore: secrets, dependencies (`node_modules/`), build artifacts, OS files (`.DS_Store`, `Thumbs.db`), editor files (`.idea/`, `.vscode/`)
- Use [github.com/github/gitignore](https://github.com/github/gitignore) for language/framework templates
- Personal preferences (editor config, OS files) go in `~/.gitignore_global` — don't pollute the project `.gitignore`

---

## Cherry-Pick

Use cherry-pick **only for hotfixes** that need to be applied to multiple branches. It is not a substitute for merge or rebase.

```bash
# Apply a specific fix commit to a release branch
git checkout release/2.1
git cherry-pick abc1234 -x   # -x appends origin note to commit message
```

- Always use `-x` so the commit message records where the cherry-pick came from
- After the feature branch merges, clean up duplicated commits with rebase
- Never use cherry-pick as a regular integration strategy — it creates duplicate SHAs and messy history

---

## Stashing

Use stash for **short-term context switches** only. For anything longer than a few minutes, use a branch.

```bash
git stash push -m "wip: half-done login form validation"
git stash list
git stash pop
git stash drop stash@{0}   # clean up stashes you no longer need
```

- Always add a descriptive message — `git stash list` becomes unreadable otherwise
- Stash is local only — not visible to teammates
- Regularly clean up old stashes: `git stash drop` or `git stash clear`

---

## Large Files

- Never commit large binary files directly to git — they bloat the repo permanently
- Use **Git LFS** for large assets: images, videos, audio, datasets, compiled binaries
- Commit `.gitattributes` (LFS config) to the repo so all team members use LFS automatically

```bash
git lfs track "*.psd"
git lfs track "*.mp4"
git add .gitattributes
```

---

## Collaboration Etiquette

- **Pull before you push** — always fetch/pull latest before starting work to minimize conflicts
- **Keep branches short-lived** — long-lived branches diverge and become painful to merge
- **Never commit directly to main** — always use a branch + PR, even for tiny fixes
- **Don't commit IDE or OS files** — configure your global `.gitignore` instead
- **Communicate before rebasing shared branches** — if you must, warn the team first
- Document your team's Git workflow in `CONTRIBUTING.md` so onboarding is frictionless
