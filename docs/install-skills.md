# Install third-party skills

Skills listed in `policy.yaml` under `skills` with an `install` key are installed in every environment, and `dist/INSTALL.md` lists the commands. The only one today is Jev.

## Jev

Jev is a shared agent skill published by TypeSafe: `typesafe-ai/skills`, path `skills/typesafe-ai`. Installation instructions: <https://docs.typesafe.ai/agent-skill>.

### Install

Cursor, Cloud Agents and Grok Build use the skills.sh installer. It is project-local by default and prompts for the agent:

```bash
npx skills add typesafe-ai/skills --skill typesafe-ai
```

Global install:

```bash
npx skills add typesafe-ai/skills --skill typesafe-ai -g
```

Update:

```bash
npx skills update
```

Grok Bots: copy the pinned `skills/typesafe-ai` directory, including its reference files, into the shared skill library. TypeSafe advises one installation method per agent to avoid duplicate copies.

## Version pinning

- `policy.yaml` lists the skill under `skills` with `version: unpinned`. Before rollout, pin it to a commit SHA so `make render` and `make check` keep every environment on the same version.
- TypeSafe notes that a stale skill can make agents invent request or response fields, so updates should follow the pin, not drift.
- Review TypeSafe's telemetry terms before rollout (flagged earlier as a carve-out to watch; not re-verified here).

## References

- [TypeSafe agent skill docs](https://docs.typesafe.ai/agent-skill)
- [typesafe-ai/skills](https://github.com/typesafe-ai/skills)
- [Decision D10](decisions.md)
