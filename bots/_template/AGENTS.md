# Bot name

Copy this directory to `bots/<bot>/`, replace the title and every `<bot>` with the bot's name, fill it in, add the bot to `etc/registry.json`, then run `make render`.

## Role

One sentence: what this bot does and for whom.

## Owned paths

- `/workspace/bots/<bot>/`
- `/workspace/run/<bot>/status.json`
- `/workspace/var/log/<bot>/`

## Reads

- `/workspace/etc/registry.json`
- List other paths this bot reads.

## Triggers

- Messages, routines (with schedule) or webhooks that start a turn.

## Limits

- Guidelines only: expected turns per day, reply length, tools it may use.

## Escalation

- What it must ask the user before doing.
