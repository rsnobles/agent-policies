# Workspace layout

`/workspace` is laid out like a small Unix system, after the Filesystem Hierarchy Standard (FHS). The canonical list is `workspace.layout` in [policy.yaml](../policy.yaml).

## Tree

```text
/workspace/
  bots/<bot>/            # a bot's private working files and its AGENTS.md copy
  src/<repo>/            # git checkouts, like /usr/src (agent-policies lives here)
  srv/<service>/         # long-running services, e.g. srv/alloy
  etc/<name>/            # installed configuration
  etc/registry.json      # manifest of bots and services: owner, paths, ports
  run/<bot>/status.json  # current state, rewritten atomically each turn
  shared/                # files deliberately shared between bots
  tmp/                   # scratch, may be wiped
  var/lib/<name>/        # persistent state that is not config
  var/log/<bot>/         # append-only logs, one JSON line per turn
  var/metrics/           # *.prom files for Alloy
  var/spool/<queue>/     # work queues (temp then rename in)
  var/archive/           # retired bots and old artifacts
```

## FHS mapping

Each top-level directory borrows the role of its FHS namesake, so anyone who knows Unix can find things.

<details>
<summary>FHS-to-workspace mapping table (7 rows)</summary>

| FHS | Here | Why |
| --- | --- | --- |
| `/home/<user>` | `bots/<bot>/` | Each principal's own space |
| `/usr/src` | `src/<repo>/` | Source checkouts |
| `/srv` | `srv/<service>/` | Data and binaries for a served service |
| `/etc` | `etc/` | Config installed from `agent-policies` builds |
| `/run`, `/proc` | `run/<bot>/status.json` | Runtime state (see below) |
| `/var/log`, `/var/spool`, `/var/lib` | `var/...` | Variable data |
| `/tmp` | `tmp/` | Scratch |

</details>

## Why no proc/

Linux `/proc` is a virtual filesystem the kernel generates on every read. Nothing in the workspace can do that without a daemon running all the time, and bots are not daemons. The honest equivalent is `run/<bot>/status.json`, written atomically by each bot at the end of its turn and read like any file.

## Rules

- Ownership by path: only the owning bot writes its subtree; everyone else reads (`OWN-1`).
- Register first: a new bot or service gets an `etc/registry.json` entry before it writes (`OWN-2`).
- Atomic handoff: write a temp file in the target directory, then `rename()` it into place, for example into `var/spool/<queue>/` (`ATOM-1`).
- No secrets anywhere in the tree (`SEC-1`).
- Retiring a bot touches a fixed set: `bots/<bot>/`, `run/<bot>/`, `var/log/<bot>/` (moved to `var/archive/`) and its registry entry (`RET-1`).

## Skeleton script

`scripts/workspace-skeleton.sh` creates the tree with `mkdir -p` and writes an empty `etc/registry.json` by atomic rename. It never deletes or moves anything, and it skips an existing registry. `WORKSPACE_ROOT` overrides the target (default `/workspace`).

Preview without changing anything:

```bash
make skeleton-dry-run
```

Run the tests (they use a temp directory, never `/workspace`):

```bash
bash scripts/workspace-skeleton.test.sh
```

The test checks: the dry run creates nothing, all 12 directories are created, the registry is valid JSON with no temp file left behind, existing files are untouched, and a second run changes nothing. Running it for real on `/workspace` is waiting on user approval.

```bash
bash scripts/workspace-skeleton.sh
```

## References

- [Filesystem Hierarchy Standard 3.0](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)
- [Threat model](threat-model.md): why ownership is a convention
- [Decisions D3, D4 and D5](decisions.md)
- `workspace.layout` in [policy.yaml](../policy.yaml)
