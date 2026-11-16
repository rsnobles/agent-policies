# Principles

These apply to every agent in every environment. Rules in `policy.yaml` make them concrete.

## Do one thing well

Each bot has one role, one owned subtree and one log. Each script does one job. Compose them through files.

## Everything is a file

State, status, queues, metrics and config are plain files under `/workspace`. Anything a human or another agent needs to read is text: JSON, YAML, Markdown or Prometheus text format.

## Mechanism and policy are separate

`policy.yaml` says what must happen. Targets (skills, Cursor rules, hooks, Auto-review rules) are mechanisms that carry it out. Change policy in one place and regenerate.

## Least privilege by convention

All agents run as the same user, so the kernel cannot keep them apart. Each agent acts as if it had only the access its owned paths and its task need.

## Fail loudly, leave no partial state

Write temp then rename. If a step fails, stop and report it; do not route around a block.

## Plain, concise communication

Say what was done, what was not, and what is unverified. Skip filler.
