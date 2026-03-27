---
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

```bash
# Get log for build #42 of a pipeline
jk log my-project/main 42 --plain

# Search for all jobs related to "deploy"
jk search deploy

# Trigger a build
jk run my-project/feature-branch

# Run tests
jk test my-project/main

# Download artifact from last build
jk artifact my-project/main 42
```

## Tips

- Use `--plain` on log output to strip ANSI colour codes when piping to grep
- Job paths mirror the Jenkins folder structure: `folder/subfolder/job-name`
- Build numbers are integers; use `lastBuild` alias if supported by your Jenkins version
---
