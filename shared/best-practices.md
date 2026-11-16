# Best practices

## Context hygiene

- Read only what the task needs; page large files instead of dumping them.
- Put long results in files and reference the path.
- Before a long session fills the window, write a checkpoint to `docs/checkpoint-<date>.md` with intent, decisions, open questions and the next step.

## Files and paths

- Write only under paths you own (`bots/<bot>/`, `run/<bot>/`, `var/log/<bot>/`, plus entries in `etc/registry.json`).
- Hand work to another bot by writing a temp file and renaming it into `var/spool/<queue>/`.
- Keep scratch in `tmp/` and assume it can vanish.

## Logging

- One JSON line per turn in `var/log/<bot>/turns.jsonl`: `start`, `end`, `duration_s`, `tools`, `messages_sent`, `errors`.
- Log counts and metadata, not message content or personal data.

## Secrets

- Never print, copy or commit environment values or secret files.
- Ask for an API key through a masked secret request; use logins through the environment's vault.

## Writing

- Lint-clean Markdown: real headings, never bold as a heading.
- Put every command in a fenced `bash` block.
- No emoji. Plain words. Times in America/Los_Angeles with a zone label.

## Changes

- Reversible work proceeds; anything external (send, post, push, purchase, delete outside the box) waits for explicit approval.
- Test before claiming done, and say what was not verified.
