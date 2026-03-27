# claude-good-boy Initial Build Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build `claude-good-boy` — a public, stack-agnostic shared Claude Code rules repo at `C:\Sources\claude-good-boy` with rich documentation, examples, and a one-liner setup script.

**Architecture:** Rules live in `rules/<category>/` subdirectories and are auto-discovered by Claude Code when cloned to `~/.claude/rules/shared/`. A `setup.sh` handles first-time clone + hook injection, and a `SessionStart` hook keeps rules auto-updated on every session.

**Tech Stack:** Bash, Python 3 (for JSON merging in setup.sh), Markdown, Git

---

### Task 1: Initialize git repo and folder structure

**Files:**
- Create: `C:\Sources\claude-good-boy\` (already exists)
- Create: `rules/general/`, `rules/backend/`, `rules/frontend/`, `rules/tools/`

**Step 1: Init git and create folder structure**

```bash
cd C:/Sources/claude-good-boy
git init
mkdir -p rules/general rules/backend rules/frontend rules/tools
```

**Step 2: Verify structure**

```bash
ls rules/
# expected: general/  backend/  frontend/  tools/
```

**Step 3: Commit skeleton**

```bash
git add .
git commit -m "chore: initialize repo structure"
```

---

### Task 2: Write rules/general/git.md (rich, with examples)

**Files:**
- Create: `rules/general/git.md`

**Content:** Conventional commits format, branch naming, good/bad examples, what to never do. No paths frontmatter — applies globally.

**Step 1: Write the file** (see full content in implementation notes below)

**Step 2: Verify it renders correctly**

Open in a markdown viewer or check with `cat rules/general/git.md`

**Step 3: Commit**

```bash
git add rules/general/git.md
git commit -m "feat: add git conventions rule with examples"
```

**Implementation notes — full file content:**

```markdown
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
feat(auth): add OAuth2 login with Google
fix(api): return 404 instead of 500 when user not found
chore(deps): upgrade Spring Boot to 3.5.1
refactor(order): extract payment logic into PaymentService
docs: add setup instructions to README
test(user): add edge case for duplicate email registration

### Bad examples
❌ fixed bug              — no type, vague
❌ WIP                    — never commit WIP to shared branches
❌ feat: Added the thing. — past tense, capital, period
❌ fix: lots of changes   — too vague, should be split into multiple commits
❌ HOTFIX URGENT!!!       — no type, shouting

## Branch Naming

Format: `<type>/<ticket-or-short-description>`

### Good examples
feat/user-authentication
fix/VAD-123-login-redirect-loop
chore/upgrade-angular-19
refactor/extract-payment-service

### Bad examples
❌ my-branch
❌ fix
❌ johns-work-march

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
```

---

### Task 3: Write rules/backend/java-spring.md

**Files:**
- Create: `rules/backend/java-spring.md`

**Step 1: Write the file**

Path-scoped to `**/*.java` so it only loads when working on Java files.

**Step 2: Commit**

```bash
git add rules/backend/java-spring.md
git commit -m "feat: add Java 21 + Spring Boot backend rules"
```

**Implementation notes — full file content:**

```markdown
---
paths:
  - "**/*.java"
---

# Backend Conventions — Java 21 + Spring Boot

## Layered Architecture

Controller → Service → Repository

Dependencies flow downward only. Each layer has one job.

| Layer | Responsibility | Never |
|---|---|---|
| **Controller** | Validate input, delegate to service, return response | Business logic, repo calls, `@Transactional` |
| **Service** | All business logic and orchestration. `@Transactional` on write methods | Return JPA entities, throw `ResponseStatusException` |
| **Repository** | CRUD + JPQL/native queries | Business logic, mapping |

Controllers max ~5 lines per method:
\`\`\`java
// Good
@GetMapping("/{id}")
public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
    return ResponseEntity.ok(userService.getById(id));
}

// Bad — business logic in controller
@GetMapping("/{id}")
public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
    User user = userRepository.findById(id).orElseThrow();
    if (!user.isActive()) throw new ResponseStatusException(HttpStatus.FORBIDDEN);
    return ResponseEntity.ok(new UserDto(user.getId(), user.getName()));
}
\`\`\`

## Lombok — MANDATORY

- `@RequiredArgsConstructor` for constructor injection (+ `private final` fields)
- `@Getter @Setter` on entities and config properties
- `@NoArgsConstructor` on JPA entities
- `@Slf4j` for logging — never `LoggerFactory.getLogger()`
- `@Builder` for objects with 3+ fields
- Never `@Autowired` field injection

\`\`\`java
// Good
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
}

// Bad
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
}
\`\`\`

## Java 21 Patterns

- **Records for read-only DTOs:**
\`\`\`java
public record UserDto(Long id, String name, String email) {}
\`\`\`
- **Text blocks** for multi-line strings:
\`\`\`java
String query = """
    SELECT u FROM User u
    WHERE u.active = true
    ORDER BY u.name
    """;
\`\`\`
- **Pattern matching** for instanceof:
\`\`\`java
// Good
if (event instanceof OrderPlaced placed) {
    process(placed.orderId());
}
// Bad
if (event instanceof OrderPlaced) {
    process(((OrderPlaced) event).orderId());
}
\`\`\`

## Code Style

- Guard clauses / early returns — max 2 nesting levels
- Methods ≤ ~30 lines
- Services ≤ ~250 lines — split by responsibility if larger
- `private static final` for constants
- Stream API for collections
- `ResponseEntity.ok()`, `.created()`, `.noContent()` — never `new ResponseEntity<>()`
- `@ConfigurationProperties` for all app properties — never `@Value` for app config

## JPA Entities

\`\`\`java
@Entity
@Table(name = "users")
@Getter @Setter @NoArgsConstructor
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;
}
\`\`\`

- Keep entities as data holders — no business logic
- Use `@Column(nullable = false)` to mirror DB constraints
- Prefer `Optional<T>` from repository methods, don't `.get()` without check
```

---

### Task 4: Write rules/frontend/angular.md

**Files:**
- Create: `rules/frontend/angular.md`

**Step 1: Write the file** — path-scoped to frontend files

**Step 2: Commit**

```bash
git add rules/frontend/angular.md
git commit -m "feat: add Angular 19 + PrimeNG frontend rules"
```

**Implementation notes — full file content:**

```markdown
---
paths:
  - "frontend/**/*.ts"
  - "frontend/**/*.html"
  - "frontend/**/*.scss"
  - "*/frontend/**/*.ts"
  - "*/frontend/**/*.html"
  - "*/frontend/**/*.scss"
  - "**/*.component.ts"
  - "**/*.component.html"
---

# Frontend Conventions — Angular 19 + PrimeNG

## Component Architecture

- **Standalone components only** — no NgModules
- **OnPush change detection** on every component
- **Lazy loading** all routes via `loadComponent()`
- **Separate `.html` and `.scss` files** — inline `template` only if ≤ 3 lines

\`\`\`typescript
// Good
@Component({
  selector: 'app-user-list',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './user-list.component.html',
  styleUrl: './user-list.component.scss',
  imports: [CommonModule, TableModule, SkeletonModule],
})
export class UserListComponent {}
\`\`\`

## Reactivity — MANDATORY

- **All state must be signals or observables** — never plain mutable variables
- **Prefer `| async` pipe** in templates over manual `subscribe()`
- `signal()` for local UI state only (toggles, form values)
- `computed()` for derived state from signals
- `subscribe()` only for side effects — always `takeUntilDestroyed()` in constructor
- `toSignal()` only when combining multiple streams into computed state
- Services expose **observables**, never plain properties

\`\`\`typescript
// Good — async pipe manages subscription
users$ = this.userService.getUsers();

// Good — signal for local UI state
isMenuOpen = signal(false);

// Bad — plain variable for async data
users: User[] = [];
ngOnInit() { this.userService.getUsers().subscribe(u => this.users = u); }
\`\`\`

## Templates

- **No method calls in templates** — use `computed()`, pipes, or inline expressions
- **Pipes in `shared/pipes/`** for formatting and CSS class mapping
- **Const lookup maps** instead of switch/if-else chains

\`\`\`html
<!-- Good -->
@if (users$ | async; as users) {
  <p-table [value]="users">...</p-table>
} @else {
  <p-skeleton height="2rem" />
}

<!-- Bad — method call in template re-runs on every change detection -->
<p>{{ formatUser(user) }}</p>
\`\`\`

## Loading States — MANDATORY

Every async data load must show a skeleton while pending. Never show blank space.

\`\`\`html
@if (data$ | async; as data) {
  <!-- real content -->
} @else {
  <p-skeleton height="1.5rem" styleClass="mb-2" />
  <p-skeleton height="1.5rem" styleClass="mb-2" />
  <p-skeleton height="1.5rem" />
}
\`\`\`

## Models

- One interface per file in `core/models/`, named `<entity>.model.ts`
- Import from specific file, not barrel exports

## Styling

- **Tailwind CSS** for layout, spacing, flexbox
- **PrimeNG** for interactive components (buttons, tables, toggles, drawers, skeletons)
- **SCSS** for component-specific styles
```

---

### Task 5: Write rules/tools/jenkins.md

**Files:**
- Create: `rules/tools/jenkins.md`

**Step 1: Write the file**

**Step 2: Commit**

```bash
git add rules/tools/jenkins.md
git commit -m "feat: add Jenkins CLI tool rules"
```

**Implementation notes — full file content:**

```markdown
# Jenkins CLI

The Jenkins CLI is available as `jk` at `~/bin/jk.exe`.

## Common Commands

| Command | Purpose |
|---------|---------|
| `jk log <jobPath> <buildNumber> --plain` | Fetch build log as plain text |
| `jk search <query>` | Search for jobs |
| `jk run <jobPath>` | Trigger a build |
| `jk test <jobPath>` | Run tests for a job |
| `jk artifact <jobPath> <buildNumber>` | Download build artifacts |

Run `jk <command> --help` for full usage of any command.

## Examples

\`\`\`bash
# Get log for build #42 of a pipeline
jk log my-project/main 42 --plain

# Search for all jobs related to "deploy"
jk search deploy

# Trigger a build
jk run my-project/feature-branch
\`\`\`
```

---

### Task 6: Write setup.sh with real GitHub URL

**Files:**
- Create: `setup.sh`

**Step 1: Write the file** with `https://github.com/vado-consulting/claude-good-boy` as `REPO_URL`

**Step 2: Verify it's executable**

```bash
chmod +x setup.sh
bash -n setup.sh  # syntax check
```

**Step 3: Commit**

```bash
git add setup.sh
git commit -m "feat: add one-liner setup script"
```

**Implementation notes — full file content:**

```bash
#!/usr/bin/env bash
# claude-good-boy setup — one-liner installer
# Usage: bash <(curl -s https://raw.githubusercontent.com/vado-consulting/claude-good-boy/main/setup.sh)

set -e

REPO_URL="https://github.com/vado-consulting/claude-good-boy"
RULES_DIR="$HOME/.claude/rules/shared"
SETTINGS_FILE="$HOME/.claude/settings.json"
HOOK_COMMAND='cd "$HOME/.claude/rules/shared" && git pull --ff-only 2>/dev/null || true'

echo "🐶 claude-good-boy setup"
echo "─────────────────────────────────────"

# ── 1. Clone or update ───────────────────────────────────────────────────────
if [ -d "$RULES_DIR/.git" ]; then
  echo "→ Updating existing rules..."
  git -C "$RULES_DIR" pull --ff-only
else
  echo "→ Cloning rules into $RULES_DIR..."
  mkdir -p "$(dirname "$RULES_DIR")"
  git clone "$REPO_URL" "$RULES_DIR"
fi

# ── 2. Inject SessionStart hook ───────────────────────────────────────────────
mkdir -p "$(dirname "$SETTINGS_FILE")"

python3 - <<PYEOF
import json, os

settings_file = os.path.expanduser("~/.claude/settings.json")
hook_command = 'cd "\$HOME/.claude/rules/shared" && git pull --ff-only 2>/dev/null || true'

settings = {}
if os.path.exists(settings_file):
    with open(settings_file) as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            print("  Warning: could not parse existing settings.json, starting fresh")

settings.setdefault("hooks", {})
settings["hooks"].setdefault("SessionStart", [])

existing = [
    h.get("command", "")
    for entry in settings["hooks"]["SessionStart"]
    for h in entry.get("hooks", [])
]

if hook_command in existing:
    print("→ Hook already present — nothing to do.")
else:
    settings["hooks"]["SessionStart"].append({
        "hooks": [{
            "type": "command",
            "command": hook_command,
            "async": True,
            "statusMessage": "Updating shared rules..."
        }]
    })
    with open(settings_file, "w") as f:
        json.dump(settings, f, indent=2)
    print(f"→ Hook added to {settings_file}")
PYEOF

echo ""
echo "✓ Done! claude-good-boy rules are ready."
echo "  Rules auto-update on every Claude Code session start."
echo ""
echo "  Add personal overrides in: ~/.claude/rules/ (outside shared/)"
```

---

### Task 7: Write README.md

**Files:**
- Create: `README.md`

**Step 1: Write the file** — comprehensive, with badges, setup instructions, stack table, override docs

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README"
```

---

### Task 8: Write CONTRIBUTING.md

**Files:**
- Create: `CONTRIBUTING.md`

**Step 1: Write the file** — how to add a new rule file, frontmatter format, PR guidelines

**Step 2: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "docs: add CONTRIBUTING guide"
```

---

### Task 9: Reconfigure ~/.claude/rules/shared to point to new repo

**Step 1: Remove old shared rules dir**

```bash
rm -rf "$HOME/.claude/rules/shared"
```

**Step 2: Clone the new repo there**

```bash
git clone C:/Sources/claude-good-boy "$HOME/.claude/rules/shared"
```

(Uses local path as remote until pushed to GitHub — works fine for now)

**Step 3: Verify**

```bash
ls "$HOME/.claude/rules/shared/rules/"
# expected: general/  backend/  frontend/  tools/
```

---

### Task 10: Set GitHub remote and push

**Step 1: Add remote**

```bash
cd C:/Sources/claude-good-boy
git remote add origin https://github.com/vado-consulting/claude-good-boy
```

**Step 2: Push**

```bash
git push -u origin main
```

**Step 3: Update ~/.claude/rules/shared remote**

```bash
cd "$HOME/.claude/rules/shared"
git remote set-url origin https://github.com/vado-consulting/claude-good-boy
```
