# Decision log

Short ADR-style records, newest last. Status is Accepted unless noted. D1 and D2 concerned one machine's cleanup and are kept in local notes.

## Summary

| ID | Decision | Date | Status |
| --- | --- | --- | --- |
| D3 | FHS-style /workspace | 2026-10-30 | Proposed |
| D4 | No proc/ directory | 2026-10-31 | Accepted |
| D5 | Ownership by convention under one OS user | 2026-10-30 | Accepted |
| D6 | One policy repo | 2026-10-31 | Accepted |
| D7 | Name it agent-policies | 2026-10-31 | Accepted |
| D8 | Rename common/ to shared/ | 2026-10-31 | Accepted |
| D9 | No cloud-agents/ directory | 2026-10-31 | Accepted |
| D10 | Jev as a shared TypeSafe skill | 2026-10-31 | Accepted |
| D11 | Commit dist/ | 2026-10-31 | Accepted |
| D12 | Hosted on GitHub | 2026-11-01 | Accepted |
| D13 | Public repo with a fresh history | 2026-11-16 | Accepted |
| D14 | Security baseline: gitleaks, rulesets, Scorecard | 2026-11-16 | Accepted |
| D15 | Background notes stay local | 2026-11-16 | Accepted |

## Records

<details>
<summary>Full decision records: context, rationale and consequences</summary>

### D3. FHS-style /workspace (2026-10-30, proposed)

- Decision: lay out `/workspace` like a Unix system ([workspace-layout.md](workspace-layout.md)).
- Status: Proposed; running the skeleton script awaits approval.

### D4. No proc/ directory (2026-10-31)

- Decision: use `run/<bot>/status.json` instead of a `proc/` tree.
- Why: `/proc` is kernel-generated on read; we have no daemon to emulate it, and a stale imitation would mislead.

### D5. Ownership by convention under one OS user (2026-10-30)

- Decision: enforce path ownership with rules, the registry, the skill, Auto-review and checks.
- Why: all bots run as the same OS user, so file permissions cannot separate them ([threat model](threat-model.md)).
- Trade-off: simple sharing in exchange for cooperative, not kernel-enforced, isolation.

### D6. One policy repo (2026-10-31)

- Decision: a single repo renders every target from one `policy.yaml`.
- Why: rules are the same everywhere; only formats differ. One version stamp prevents drift.
- Consequence: a second repo only for real bot or service code later, consuming `dist/`.

### D7. Name it agent-policies (2026-10-31)

- Decision: the repo and its directory are both `agent-policies`, at `/workspace/src/agent-policies`.

### D8. Rename common/ to shared/ (2026-10-31)

- Decision: shared prose lives in `shared/`.

### D9. No cloud-agents/ directory (2026-10-31)

- Decision: Cloud Agents take their environment from the repo they run on, so `targets/cursor/` covers them.

### D10. Jev as a shared TypeSafe skill (2026-10-31)

- Decision: Jev comes from `typesafe-ai/skills`, installed per environment and pinned in `policy.yaml` ([install-skills.md](install-skills.md)).

### D11. Commit dist/ (2026-10-31)

- Decision: generated artifacts are committed and drift-checked by `make check`.
- Why: reviewable diffs of what each environment reads; install without a toolchain.

### D12. Hosted on GitHub (2026-11-01)

- Decision: [github.com/rsnobles/agent-policies](https://github.com/rsnobles/agent-policies) is the single source; working copies clone from it.
- Why: ecosystem reach (Cloud Agents, Cursor, Grok Build, `npx skills`) and Actions CI.

### D13. Public repo with a fresh history (2026-11-16)

- Decision: publish the repo, starting from one clean commit after the doc split.
- Why: public repos get rulesets, secret scanning and code scanning on the Free plan. A fresh start keeps machine notes and a personal email out of public history.

### D14. Security baseline (2026-11-16)

- Decision: gitleaks replaces the custom secret scan; `main` requires a PR and passing checks; Actions are pinned to full SHAs; OpenSSF Scorecard runs weekly; target OSPS Baseline Level 1.
- Why: maintained open-source tools over custom code; enforcement claims must match a real mechanism.

### D15. Background notes stay local (2026-11-16)

- Decision: notes about specific machines, vaults and retired bots live in the Git-ignored `local/` directory; environment-specific values go in `policy.local.yaml`.
- Consequence: those files need their own backup.

</details>

## References

- [Threat model](threat-model.md) and [workspace layout](workspace-layout.md)
- [Roadmap](roadmap.md) for decisions still pending
