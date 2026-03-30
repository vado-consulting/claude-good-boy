---
paths:
  - "**/pom.xml"
  - "**/bom.xml"
---

# Maven Conventions

## Dependencies — MANDATORY

**Never add, remove, or change dependencies (including version, scope, or exclusion changes) without asking first.** If you think a dependency change is needed, explain why and wait for explicit approval.

Exception: once the user explicitly asks you to add, remove, or update a specific dependency in this conversation, you may do so without asking again for that same change.

This applies to `<dependencies>`, `<dependencyManagement>`, `<plugins>`, and `<pluginManagement>`.

## Declaring Dependencies

- **Always declare dependencies your code directly uses** — even if they arrive transitively today. Transitive deps can disappear when an upstream changes.
- **Never use `LATEST`, `RELEASE`, or version ranges** (`[1.0,2.0)`) — they produce non-reproducible builds that can silently change between runs.
- **Never use `system` scope** — it ties the build to a filesystem path. Deploy the JAR to the private repo instead.
- Centralise all version strings in `<properties>` — never repeat a version literal in two places.

## Dependency Scopes

| Scope | When to use |
|-------|-------------|
| `compile` | Needed at compile time and runtime (default) |
| `provided` | Provided by the container at runtime (e.g. Servlet API, Jakarta EE) |
| `runtime` | Not needed to compile, only at runtime (e.g. JDBC drivers) |
| `test` | Test code only — never leaks into the production classpath |

## dependencyManagement and BOM

- Version numbers for managed dependencies belong in `<dependencyManagement>` (parent POM or BOM), not in child `pom.xml` files — child modules omit `<version>` entirely.
- To override a BOM-managed version, declare the dependency in `<dependencyManagement>` before the BOM import with an explicit version and a comment explaining why.
- Keep BOM POMs focused: only `<dependencyManagement>`, no `<dependencies>`, no plugins.

## Plugin Management

- **Lock every plugin version in `<pluginManagement>`** — Maven silently resolves un-versioned plugins to whatever is current, breaking builds when new major versions release.
- `<pluginManagement>` declares versions and config but does not execute. `<plugins>` activates execution. Define management in the parent; activate in child modules only where needed.
- Always lock these core lifecycle plugins as they are implicitly present in every build: `maven-compiler-plugin`, `maven-surefire-plugin`, `maven-failsafe-plugin`, `maven-jar-plugin`, `maven-resources-plugin`.

## Testing

- **`maven-surefire-plugin`** runs unit tests (`*Test.java`, `*Tests.java`) in the `test` phase.
- **`maven-failsafe-plugin`** runs integration tests (`*IT.java`, `*ITCase.java`) in the `integration-test` + `verify` phases — always runs teardown even on failure.
- Never run integration tests with Surefire — a failure skips teardown and leaves infra dirty.
- Run integration tests with `mvn verify`, not `mvn test`.

## Useful Commands

| Command | Purpose |
|---------|---------|
| `mvn dependency:tree` | Inspect the full dependency tree |
| `mvn dependency:analyze` | Find unused declared or undeclared-but-used deps |
| `mvn versions:display-dependency-updates` | List available version upgrades |
| `mvn versions:display-plugin-updates` | List available plugin upgrades |

## Security

- **Never commit credentials to pom.xml** — repository credentials belong in `~/.m2/settings.xml` server entries only.
- **Never add `<repositories>` or `<pluginRepositories>` to project POMs** — keep all repo config in `settings.xml`. It leaks internal URLs and reduces portability.
- **Never use `http://` repository URLs** — Maven 3.8+ blocks them by default; do not add exceptions, fix the URL.
- Never run `mvn dependency:resolve -U --force-update-snapshots` without asking.
- Avoid `-DskipTests` unless the user explicitly asks — hidden test failures are dangerous.
- **Never introduce a SNAPSHOT dependency in a release POM** without asking — releases must be reproducible.
- Never run `mvn versions:use-latest-releases` without reviewing the output and asking first — it can silently introduce breaking changes.
