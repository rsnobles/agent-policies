# Glossary

| Term | Meaning |
| --- | --- |
| Grok Bot | An agent in xAI's Grok Bots app. All of an account's bots share one Linux workspace |
| Auto-review | The Grok Bots app feature that checks risky tool calls before they run. The repo renders starter rules for it; they are applied by hand |
| Cursor, Cloud Agents | Cursor's editor agent and its remote agents. Both read `AGENTS.md`, `.cursor/rules/` and `.cursor/hooks.json` from the repo they work on |
| Grok Build | xAI's coding agent CLI. It reads `AGENTS.md` |
| Target | One environment's output format, defined by templates in `targets/<name>/` |
| `dist/` | Rendered output for all targets. Committed, never edited by hand |
| Drift | A difference between `dist/` and what `make render` would produce now. `make check` fails on drift |
| Guard hook | `guard-shell.py`, which Cursor runs before each shell command to allow, ask or deny it |
| Jev | A shared agent skill from TypeSafe (`typesafe-ai/skills`), installed in every environment; see [install-skills.md](install-skills.md) |
| `policy.local.yaml` | Environment-specific values (for example secret names the guard should block). Ignored by Git; merged only when `AGENT_POLICIES_LOCAL=1` |

## ID schemes

| Form | Example | Meaning |
| --- | --- | --- |
| Rule ID | `OWN-1`, `SEC-2` | A rule in `policy.yaml`. The prefix is the topic: OWN ownership, ATOM atomic handoff, SEC secrets, LOG logging, RUN status, GIT Git safety, CTX context, DOC docs, RET retirement |
| Hook ID | `deny-env-dump` | A guard intent in `policy.yaml` under `hooks` |
| Decision ID | `D6` | An entry in [decisions.md](decisions.md) |
