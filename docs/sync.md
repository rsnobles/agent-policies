# Keeping environments in sync

## One repo

`agent-policies` is the single source of truth. Targets differ only in file format, so one `policy.yaml` with one version stamp avoids drift between them. A second repo makes sense only later, for actual bot or service code; it consumes this repo's `dist/` instead of copying rules.

## Source and targets

```text
policy.yaml + shared/ + bots/ + targets/*/  --make render-->  dist/
```

| Target | Source | Output |
| --- | --- | --- |
| Grok Bot | `targets/grok-bot/` | `dist/grok-bot/workspace-conventions/SKILL.md`, `dist/grok-bot/auto-review-rules.md` |
| Cursor and Cloud Agents | `targets/cursor/` | `dist/cursor/AGENTS.md`, `dist/cursor/.cursor/{rules,hooks,hooks.json,environment.json,install.sh}` |
| Grok Build | `targets/grok-build/` | `dist/grok-build/AGENTS.md` (paths provisional) |
| Per bot | `bots/<bot>/AGENTS.md` | `dist/bots/<bot>/AGENTS.md` |
| All | `targets/INSTALL.md.tmpl` | `dist/INSTALL.md`, `dist/VERSION` |

Cloud Agents need no target of their own: they read `.cursor/` and `AGENTS.md` from whatever repo they run on.

## Version stamps

- `version` in `policy.yaml` follows semantic versioning: patch for wording, minor for a new rule, major for a removed or reversed rule.
- Every Markdown, `.mdc` and script output carries the version in a generated-file header; `dist/VERSION` holds it alone.

## Drift checks

- `make check` renders into a temp directory and diffs it against the committed `dist/`. Any difference fails.
- The `pre-commit` hook runs it, so a policy change cannot be committed without its rendered output.
- Planned: a weekly routine that compares installed copies (the skill library, each repo's `.cursor/`) against `dist/VERSION` and reports stale ones.

## Why dist/ is committed

Generated artifacts are committed so every rule change shows up as a reviewable diff in the output each environment actually reads, and so consumers can install from a checkout without Python or PyYAML.

## References

- [Decisions D6 and D11](decisions.md)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [dist/INSTALL.md](../dist/INSTALL.md)
