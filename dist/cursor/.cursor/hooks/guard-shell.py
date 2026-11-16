#!/usr/bin/env python3
"""Cursor beforeShellExecution guard for agent-policies.

A guardrail, not a security boundary: it catches common mistakes, not a
determined bypass (for example `python -c`, base64, or a script file).
Real enforcement lives server-side (GitHub rulesets, push protection) and in
what the environment exposes. Fails closed: any error returns "ask".
"""
import json
import os
import re
import shlex
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
WRAPPERS = {"sudo", "command", "builtin", "exec", "nohup", "nice", "time", "xargs", "doas", "stdbuf"}
SHELLS = {"sh", "bash", "zsh", "dash", "ksh"}
GIT_OPTS_WITH_ARG = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}
SEPARATORS = {";", "&", "|", "&&", "||", "(", ")", "`", "$", ";;", "|&"}


def reply(permission, hook=None):
    out = {"permission": permission}
    if hook:
        msg = f"agent-policies {hook['id']}: {hook['intent']}"
        out.update(user_message=msg, agent_message=msg)
    print(json.dumps(out))
    sys.exit(0)


def split_commands(command):
    """Quote-aware split into simple commands at ; & | && || ( ) ` and newlines."""
    lex = shlex.shlex(command.replace("\n", ";"), posix=True, punctuation_chars=";&|()`")
    lex.whitespace_split = True
    lex.commenters = "#"
    cur = []
    try:
        for tok in lex:
            if tok in SEPARATORS or set(tok) <= set(";&|()`"):
                if cur:
                    yield cur
                cur = []
            else:
                cur.append(tok[1:] if tok.startswith("$") and len(tok) > 1 and cur == [] else tok)
    except ValueError:  # unbalanced quotes: fall back to a plain split
        cur = command.split()
    if cur:
        yield cur


def segments(command):
    """Yield argv lists, stripping wrappers and recursing into `sh -c`."""
    for argv in split_commands(command):
        argv = [a for a in argv if a != "$"]
        while argv and (re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", argv[0]) or os.path.basename(argv[0]) in WRAPPERS):
            argv = argv[1:]
            while argv and argv[0].startswith("-"):  # wrapper options, e.g. sudo -u x
                argv = argv[1:]
        if argv and os.path.basename(argv[0]) == "env":
            argv = argv[1:]
            while argv and (argv[0].startswith("-") or "=" in argv[0]):
                argv = argv[1:]
            if not argv:
                argv = ["env"]
        if len(argv) >= 3 and os.path.basename(argv[0]) in SHELLS and argv[1] in ("-c", "-lc"):
            yield from segments(argv[2])
        elif argv:
            argv[0] = os.path.basename(argv[0])
            yield argv


def env_dump(argv, rule):
    name, args = argv[0], argv[1:]
    if name in ("env", "printenv") or (name == "set" and not args) or (name == "compgen" and "-v" in args):
        return True
    if name in ("export", "declare", "typeset") and (not args or set(args) & {"-p", "-x", "-px"}):
        return True
    if name == "gh" and args[:2] == ["auth", "token"]:
        return True
    return any(re.search(r"/proc/[^/\s]+/environ", a) for a in args)


def remote_write(argv, rule):
    if argv[0] == "git":
        args = argv[1:]
        while args and args[0].startswith("-"):
            args = args[2:] if args[0] in GIT_OPTS_WITH_ARG else args[1:]
        if not args:
            return False
        sub = args[0]
        return (sub == "push" or (sub == "remote" and len(args) > 1 and args[1] in ("add", "set-url"))
                or "--no-verify" in args or (sub == "commit" and "-n" in args))
    if argv[0] == "gh" and len(argv) > 2:
        if argv[1] == "api":
            method = next((argv[i + 1] for i, a in enumerate(argv[:-1]) if a in ("-X", "--method")), "GET")
            return method.upper() != "GET" or any(a in ("-f", "-F", "--field", "--raw-field", "--input") for a in argv)
        return argv[2] in rule.get("gh_write", {}).get(argv[1], [])
    return False


def workspace_wipe(argv, rule, cwd):
    root = rule["root"].rstrip("/")
    protected = {root} | {f"{root}/{d}" for d in rule.get("protected_dirs", [])}
    if argv[0] == "rm":
        recursive = any(a in ("-r", "-R", "--recursive") or re.match(r"^-[a-zA-Z]*[rR]", a) for a in argv[1:])
        targets = [a for a in argv[1:] if not a.startswith("-")]
    elif argv[0] == "find":
        recursive = "-delete" in argv or "-exec" in argv
        targets = [a for a in argv[1:2]]
    else:
        return False
    for t in targets:
        p = os.path.normpath(os.path.join(cwd, t)) if not t.startswith("/") else os.path.normpath(t)
        base = p.rstrip("*").rstrip("/") or "/"
        if recursive and (base in protected or root.startswith(base + "/") or base == "/"):
            return True
    return False


def main():
    raw = sys.stdin.read()
    event = json.loads(raw) if raw.strip() else {}
    command = event.get("command") or ""
    if not command.strip():
        reply("allow")
    cwd = event.get("cwd") or os.getcwd()
    with open(os.path.join(HERE, "policy-hooks.json"), encoding="utf-8") as f:
        hooks = {h["id"]: h for h in json.load(f)["hooks"]}
    for argv in segments(command):
        for hid, hook in hooks.items():
            checks = {
                "deny-env-dump": lambda: env_dump(argv, hook) or any(
                    s in command for s in hook.get("secret_names", [])),
                "deny-remote-writes": lambda: remote_write(argv, hook),
                "deny-workspace-wipe": lambda: workspace_wipe(argv, hook, cwd),
            }
            if hid in checks and checks[hid]():
                reply(hook["action"], hook)
    reply("allow")


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:  # fail closed
        print(json.dumps({"permission": "ask", "user_message": "agent-policies guard error; review this command"}))
        sys.exit(0)
