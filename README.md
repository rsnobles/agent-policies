# agent-policies

One policy file, rendered into the rules, skills and guard hooks that each AI agent environment reads: Grok Bots, Cursor, Cursor Cloud Agents and Grok Build.

Rules are written once in `policy.yaml` and plain Markdown in `shared/`. `make render` turns them into each environment's format, and `make check` fails if the committed output drifts from the source.

## How it works

```text
policy.yaml ─┐
shared/*.md ─┼─ make render ─> dist/grok-bot/    workspace-conventions skill, Auto-review starter rules
bots/*/      │                 dist/cursor/      AGENTS.md, .cursor/rules, hooks.json, guard hook
targets/*/  ─┘                 dist/grok-build/  AGENTS.md
                               dist/bots/<bot>/  per-bot AGENTS.md
                               dist/INSTALL.md   how to install each part
```

1. Edit `policy.yaml` (rules, limits, hook intents, layout, skills) or the prose in `shared/`.
2. `make render` fills each target's templates and writes `dist/`.
3. `make check` re-renders into a temp directory and diffs it against `dist/`.
4. Each environment installs its part of `dist/` as described in [dist/INSTALL.md](dist/INSTALL.md).

Terms such as Grok Bot, Auto-review and drift are defined in the [glossary](docs/glossary.md).

## Quick start

Use it: follow [dist/INSTALL.md](dist/INSTALL.md).

| Environment | Install | Reads |
| --- | --- | --- |
| Grok Bot | Add `dist/grok-bot/workspace-conventions/` to the shared skill library and a load line to each bot | Skill, Auto-review rules |
| Cursor and Cloud Agents | Copy `dist/cursor/.` into the target repo root | `AGENTS.md`, `.cursor/rules/`, `.cursor/hooks.json` |
| Grok Build | Copy `dist/grok-build/AGENTS.md` to the project root | `AGENTS.md` |

Change it: requirements are Python 3.11+, GNU make and Node.js; the pre-commit hook also needs [gitleaks](https://github.com/gitleaks/gitleaks).

```bash
make setup
make render test lint check
make install-hooks
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow and [docs/](docs/README.md) for design and decisions.

## Limits

The Cursor shell guard and the hooks catch common mistakes. They are guardrails, not a security boundary; see the [threat model](docs/threat-model.md).

## Security and license

Report vulnerabilities as described in [SECURITY.md](SECURITY.md). Released under the [MIT License](LICENSE).
