# AGENTS.md

Instructions for any agent working in this repository.

- Edit sources only: `policy.yaml`, `shared/`, `targets/`, `bots/`, `scripts/`, `hooks/`, `docs/`. Never hand-edit `dist/`.
- After any source change, run `make render`, then `make test`, `make lint` and `make check` (`make setup` once first).
- Bump `version` in `policy.yaml` when a rule changes.
- Never add secrets or environment values; those go in `policy.local.yaml` or `local/`, which Git ignores. Never link to `local/` from a tracked file. No push, remote changes or `--no-verify` without user approval.
- Markdown must pass markdownlint: real headings, never bold as a heading, commands in fenced `bash` blocks, no emoji.
