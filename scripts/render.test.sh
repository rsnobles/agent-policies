#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2034,SC2329  # test bodies are eval-ed strings
# Tests for render.py and check.sh. Uses temp dirs only. Guard tests: guard-shell.test.sh.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok(){ if eval "$2"; then echo "ok   $1"; ((pass++)); else echo "FAIL $1"; ((fail++)); fi; }
V=$("${PYTHON:-python3}" -c 'import yaml,sys;print(yaml.safe_load(open(sys.argv[1]))["version"])' "$ROOT/policy.yaml")

"${PYTHON:-python3}" "$ROOT/scripts/render.py" "$T/a" >/dev/null
"${PYTHON:-python3}" "$ROOT/scripts/render.py" "$T/b" >/dev/null
ok "render is deterministic"              'diff -r "$T/a" "$T/b" >/dev/null'
ok "VERSION matches policy ($V)"          '[[ $(cat "$T/a/VERSION") == "$V" ]]'
ok "md, mdc, sh outputs carry version"   '! find "$T/a" -type f \( -name "*.md" -o -name "*.mdc" -o -name "*.sh" -o -name policy-hooks.json \) -exec grep -L -- "$V" {} + | grep -q .'
ok "skill has name front matter"          'head -3 "$T/a/grok-bot/workspace-conventions/SKILL.md" | grep -q "^name: workspace-conventions$"'
ok "mdc is alwaysApply"                   'grep -q "^alwaysApply: true$" "$T/a/cursor/.cursor/rules/agent-policies.mdc"'
for j in hooks.json environment.json hooks/policy-hooks.json; do
  ok "valid JSON: $j"                     'python3 -m json.tool "$T/a/cursor/.cursor/$j" >/dev/null'
done
ok "no unrendered placeholders"           '! grep -rqE "\\$\\{[a-z_]+\\}" "$T/a"'
ok "no _template bot rendered"            '[[ ! -e "$T/a/bots/_template" ]]'
ok "no temp files left"                   '[[ -z $(find "$T/a" -name "*.tmp") ]]'

ok "hooks.json fails closed"              'grep -q "\"failClosed\": true" "$T/a/cursor/.cursor/hooks.json"'
ok "no enforcement claim without a mechanism" '! grep -q "enforced by: .*check" "$T/a/cursor/AGENTS.md"'

ok "check passes on committed dist"       'bash "$ROOT/scripts/check.sh" >/dev/null'

echo "$pass passed, $fail failed"; exit $((fail>0))
