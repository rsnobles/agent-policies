# Security policy

## Reporting a vulnerability

Report vulnerabilities privately through GitHub:
**Security > Report a vulnerability** on this repository
([private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)).

Do not open a public issue for a vulnerability. Do not include real secrets or tokens in a report.

This is a single-maintainer project. Reports are acknowledged on a best-effort basis, usually within 7 days.

## Scope

In scope:

- `policy.yaml`, `scripts/`, `hooks/` and the rendered files in `dist/`
- the Cursor shell guard (`targets/cursor/guard-shell.py`): a way to run a command the guard should have stopped
- the CI workflows in `.github/workflows/`

The shell guard and hooks are guardrails that catch common mistakes. They are not a security boundary,
and they do not replace sandboxing, least-privilege tokens or secret storage.

## Supported versions

Only the latest commit on `main` is supported.
