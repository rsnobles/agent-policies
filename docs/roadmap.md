# Roadmap

## Open items

- [ ] Approve and run `scripts/workspace-skeleton.sh` on `/workspace`.
- [ ] Review the starter Auto-review rules in `dist/grok-bot/auto-review-rules.md` and add accepted ones in the app.
- [ ] Install the `workspace-conventions` skill and add the load line to each bot.
- [ ] Pin the Jev skill to a commit SHA and review TypeSafe's telemetry terms.
- [ ] Add a weekly drift-check routine for installed copies.
- [ ] Confirm Grok Build's config and plugin paths.
- [ ] Meet OSPS Baseline Level 1 and add the OpenSSF Best Practices badge.
- [ ] Add a check for `OWN-2` (registry entry before write) and `RET-1` (retirement), then change their `enforced_by`.

## Future features

- Run the `twin-builder` interview from [fszale/agent-kernel](https://github.com/fszale/agent-kernel) after the `/workspace` setup. Its outputs map onto this repo: `guardrails.md` into `policy.yaml` rules and Auto-review rules, `identity.md` and working style into the shared base of every `AGENTS.md`, and the chosen skills into the default skill set.
- Signed release tags and provenance once versions are published as releases.
