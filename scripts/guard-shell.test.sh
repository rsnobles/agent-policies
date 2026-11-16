#!/usr/bin/env bash
# Tests for the Cursor shell guard. Each case: expected permission, cwd, command.
# Portable to macOS /bin/bash 3.2. Uses the rendered guard in a temp dir.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PY="${PYTHON:-python3}"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
"$PY" "$ROOT/scripts/render.py" "$T/d" >/dev/null
G="$T/d/cursor/.cursor/hooks/guard-shell.py"
pass=0; fail=0
perm(){ "$PY" -c 'import json,sys;print(json.dumps({"command":sys.argv[1],"cwd":sys.argv[2]}))' "$2" "$1" \
  | "$PY" "$G" | "$PY" -c 'import json,sys;print(json.load(sys.stdin)["permission"])'; }
W=/workspace/src/agent-policies
while IFS='|' read -r want cwd cmd; do
  [ -z "$want" ] && continue
  case "$want" in \#*) continue ;; esac
  got=$(perm "$cwd" "$cmd")
  if [ "$got" = "$want" ]; then pass=$((pass+1)); else echo "FAIL want $want got $got: $cmd"; fail=$((fail+1)); fi
done <<CASES
deny|$W|env
deny|$W|env | sort
deny|$W|printenv HOME
deny|$W|sudo env
deny|$W|FOO=1 env
deny|$W|bash -c 'env | grep TOKEN'
deny|$W|echo \$(env)
deny|$W|export -p
deny|$W|declare -x
deny|$W|cat /proc/self/environ
deny|$W|gh auth token
deny|$W|set
allow|$W|set -euo pipefail
allow|$W|echo 'env'
ask|$W|git push
ask|$W|git -C . push origin main
ask|$W|git -c core.x=y push
ask|$W|/usr/bin/git push
ask|$W|cd x && git push
ask|$W|git remote add x y
ask|$W|git commit -n -m x
ask|$W|git commit --no-verify -m x
ask|$W|gh pr merge 1
ask|$W|gh api -X DELETE repos/a/b
ask|$W|gh api repos/a/b -f name=x
allow|$W|gh pr view 1
allow|$W|gh api repos/a/b
allow|$W|git status
allow|$W|echo git push
deny|$W|rm -rf /workspace
deny|$W|rm -rf /workspace/*
deny|$W|rm -r -f /workspace/etc
deny|$W|rm --recursive /workspace/var/
deny|$W|rm -rf ../../etc
deny|/workspace|rm -rf etc
deny|$W|rm -rf /
deny|$W|find /workspace -delete
allow|$W|rm -rf /workspace/tmp/x
allow|$W|rm -rf build
allow|$W|ls -la
CASES
empty=$(printf '' | "$PY" "$G"); bad=$(echo 'not json' | "$PY" "$G")
case "$empty" in *allow*) pass=$((pass+1)) ;; *) echo "FAIL empty input: $empty"; fail=$((fail+1)) ;; esac
case "$bad" in *ask*) pass=$((pass+1)) ;; *) echo "FAIL invalid JSON should ask: $bad"; fail=$((fail+1)) ;; esac
echo "guard: $pass passed, $fail failed"; exit $((fail>0))
