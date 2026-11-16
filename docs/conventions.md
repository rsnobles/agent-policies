# Shared conventions

Every bot and every dev environment follows the same rules. The rules live in [policy.yaml](../policy.yaml) and [shared/](../shared/); this page explains how they reach each agent.

## Grok Bots

- Enforcement point: the `workspace-conventions` skill, rendered to `dist/grok-bot/workspace-conventions/SKILL.md` and installed in the app's shared skill library, where every bot can load it.
- One line in each bot's instructions: load `workspace-conventions` at the start of every turn.
- `workspace-conventions` is a skill, not a directory. The repo is the source; the skill is one of its outputs.
- Each bot keeps a readable copy of its overlay at `/workspace/bots/<bot>/AGENTS.md`, rendered from `bots/<bot>/AGENTS.md` (start from `bots/_template/`).

## Hooks

- Grok Bots have no user-defined hooks. The closest equivalent is Auto-review, which checks risky calls before they run. `dist/grok-bot/auto-review-rules.md` is a starter rule set to propose to the user; nothing is applied automatically.
- Cursor and Cloud Agents have real hooks. `dist/cursor/.cursor/hooks.json` runs `guard-shell.py` before every shell command, with the intents from `policy-hooks.json`: deny environment dumps and `/workspace` wipes, ask before pushes and GitHub writes. The hook is set to fail closed, so a guard error asks instead of allowing.
- This repo has git hooks in `hooks/`: `pre-commit` runs gitleaks, `make lint` and `make check`; `commit-msg` caps the subject at 72 characters.

## Operational practices

- Context hygiene: read only what is needed, keep long output in files, checkpoint before the window fills (`CTX-1`).
- Log every turn to `var/log/<bot>/turns.jsonl` (`LOG-1`) and publish `run/<bot>/status.json` (`RUN-1`).
- Lint-clean Markdown, never bold as a heading, commands in fenced `bash` blocks, no emoji (`DOC-1`).

## Limits are guidelines

Token and context limits cannot be enforced per bot: usage is visible only per bot and per routine in the app's usage report. `policy.yaml` lists them under `limits` with `kind: guideline`, and a daily routine can export usage into `var/metrics/`.

## References

- [policy.yaml](../policy.yaml) rules and limits
- [shared/principles.md](../shared/principles.md) and [shared/best-practices.md](../shared/best-practices.md)
- [Cursor hooks](https://cursor.com/docs/agent/hooks)
- [Threat model](threat-model.md)
