# Contributing

1. Edit `policy.yaml`, `shared/` or `targets/`, never `dist/` directly.
2. Run `make setup` once, then `make render test lint check`.
3. Install the pre-commit hook with `make install-hooks`. It needs [gitleaks](https://github.com/gitleaks/gitleaks).
4. Open a pull request against `main`. CI must pass before merge; changes are squash-merged.

Environment-specific values (secret names, local paths) go in `policy.local.yaml`, which Git ignores.
Bump `version` in `policy.yaml` when rules change. Report security issues as described in [SECURITY.md](SECURITY.md).
