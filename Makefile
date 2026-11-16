# agent-policies: render policy.yaml into per-target artifacts and keep them in sync.
# Run `make` or `make help` to list targets.

SHELL := /bin/bash
.DEFAULT_GOAL := help
VENV ?= .venv
PYTHON ?= $(if $(wildcard $(VENV)/bin/python3),$(VENV)/bin/python3,python3)
BIN := $(if $(wildcard $(VENV)/bin),$(VENV)/bin/,)
MARKDOWNLINT ?= npx --yes markdownlint-cli2@0.22.1
SH_FILES := $(wildcard scripts/*.sh) hooks/pre-commit hooks/commit-msg dist/cursor/.cursor/install.sh

.PHONY: help setup render render-local check test lint secret-scan install-hooks skeleton-dry-run clean

help: ## List targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

setup: ## Create .venv with the pinned tools in requirements-dev.txt
	@python3 -m venv $(VENV) && $(VENV)/bin/pip install --quiet -r requirements-dev.txt && echo "setup: $(VENV) ready"

render: ## Generate dist/ for every target from policy.yaml
	@$(PYTHON) scripts/render.py dist

render-local: ## Render with Git-ignored policy.local.yaml into local/dist (never committed)
	@AGENT_POLICIES_LOCAL=1 $(PYTHON) scripts/render.py local/dist

check: ## Drift check: fresh render must match committed dist/
	@PYTHON=$(PYTHON) $(SHELL) scripts/check.sh

test: ## Run the skeleton, render and guard test suites
	@PYTHON=$(PYTHON) $(SHELL) scripts/workspace-skeleton.test.sh
	@PYTHON=$(PYTHON) $(SHELL) scripts/render.test.sh
	@PYTHON=$(PYTHON) $(SHELL) scripts/guard-shell.test.sh

lint: ## markdownlint, shellcheck, actionlint, zizmor, YAML parse. Fails if a tool is missing.
	@$(MARKDOWNLINT) "**/*.md" "#node_modules" "#local" "#.venv"
	@$(BIN)shellcheck $(SH_FILES) && echo "shellcheck: $(words $(SH_FILES)) files ok"
	@$(BIN)actionlint && echo "actionlint: ok"
	@$(BIN)zizmor --offline --quiet .github/workflows && echo "zizmor: ok"
	@$(PYTHON) -c 'import yaml; yaml.safe_load(open("policy.yaml")); print("policy.yaml: ok")'

secret-scan: ## gitleaks over the working tree and full history
	@gitleaks dir . --redact --no-banner --config .gitleaks.toml
	@gitleaks git . --redact --no-banner --config .gitleaks.toml

install-hooks: ## Point git at hooks/ (repo-local setting)
	@git config core.hooksPath hooks && echo "core.hooksPath = hooks"

skeleton-dry-run: ## Show what scripts/workspace-skeleton.sh would create in /workspace
	@$(SHELL) scripts/workspace-skeleton.sh --dry-run

clean: ## Remove untracked temp files (never touches dist/)
	@find . -name '*.tmp' -not -path './.git/*' -delete
