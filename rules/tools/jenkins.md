# Jenkins CLI

Available as `jk` at `~/bin/jk.exe`. Job paths mirror the Jenkins folder structure: `folder/subfolder/job-name`.

## Commands

| Command | Purpose |
|---------|---------|
| `jk log <jobPath> <buildNumber> --plain` | Fetch build log (use `--plain` to strip ANSI for grep) |
| `jk search <query>` | Search for jobs |
| `jk run <jobPath>` | Trigger a build |
| `jk test <jobPath>` | Run tests for a job |
| `jk artifact <jobPath> <buildNumber>` | Download build artifacts |

Run `jk <command> --help` for full usage of any command.
