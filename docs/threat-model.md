# Threat model

What the rules, hooks and checks in this repo protect against, and what they do not.

## Assets

- Credentials that agents use (API keys, logins)
- Shared files under `/workspace` and the Git repos agents work on
- GitHub state: branches, pull requests, releases, settings

## Trust assumptions

- All Grok Bots of one account share a Linux workspace and run as the same OS user. File permissions cannot keep one bot from writing another's files, so ownership is enforced by rules, not by the kernel (decision [D5](decisions.md)).
- Agents are cooperative but fallible: they can misread a task, follow injected instructions, or take a shortcut around a block.

## Controls

| Risk | Control | Strength |
| --- | --- | --- |
| A secret printed into a transcript or log | `deny-env-dump` guard; `SEC-1`, `SEC-2` | Guardrail |
| A secret committed | gitleaks in pre-commit and CI; GitHub push protection | Check |
| An unreviewed push or GitHub change | `deny-remote-writes` asks first; `main` requires a PR and passing checks | Guardrail plus ruleset |
| A recursive delete of shared roots | `deny-workspace-wipe` guard | Guardrail |
| A bot writing another bot's paths | `OWN-1` with the registry; Auto-review | Convention |
| Rules drifting between environments | `make check` in pre-commit and CI | Check |

## Not covered

- The guard parses common shell forms. An agent that writes a script file and runs it, or uses an interpreter such as `python -c`, can get past it. It is a guardrail, not a security boundary.
- Nothing here isolates agents from each other at the OS level. Use separate accounts, containers or sandboxes where that matters.
- Hooks run only where the environment supports them. Grok Bots have no hooks; Auto-review rules are applied by hand.

Report a gap as described in [SECURITY.md](../SECURITY.md).
