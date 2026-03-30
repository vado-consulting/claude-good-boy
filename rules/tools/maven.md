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

## BOM (Bill of Materials)

- Version numbers for managed dependencies belong in the BOM, not in individual `pom.xml` files
- Never hardcode a version in a child `pom.xml` if it is already managed by an imported BOM — omit `<version>` and let the BOM control it
- To override a BOM-managed version, declare the dependency in `<dependencyManagement>` with an explicit version and a comment explaining why

## Dependency Scopes

| Scope | When to use |
|-------|-------------|
| `compile` | Default — needed at compile and runtime |
| `provided` | Provided by the container at runtime (e.g. servlet API) |
| `runtime` | Not needed to compile, only at runtime (e.g. JDBC driver) |
| `test` | Test code only — never leaks into production classpath |

## Useful Commands

| Command | Purpose |
|---------|---------|
| `mvn dependency:tree` | Inspect the full dependency tree |
| `mvn dependency:analyze` | Find unused declared or used undeclared deps |
| `mvn versions:display-dependency-updates` | List available version upgrades |

## Security

- Never run `mvn dependency:resolve -U --force-update-snapshots` without asking
- Avoid `-DskipTests` unless the user explicitly asks — hidden test failures are dangerous
- SNAPSHOTs are unstable by definition — never introduce a SNAPSHOT dependency in a release POM without asking
