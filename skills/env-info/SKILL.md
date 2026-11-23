---
name: env-info
description: >-
  Inspect and summarize the current runtime environment and hardware specifications
  (manufacturer, model, CPU, memory, GPU, OS, active services, installed tools, and
  redacted .env keys). Triggered by the /env-info slash command or whenever the user
  asks for environment or hardware information. Does not report disk or space usage.
---

# Environment & Hardware Information (`/env-info`)

Read-only runbook for inspecting the host hardware specifications, operating system, workspace context, installed developer runtimes, active services, and configured environment keys.

## Guardrails

- **Read-Only**: Never modify files, install packages, or start/stop/restart services.
- **No Disk or Space Usage**: Do **not** include filesystem, disk, or directory space usage (`df`, `du`, etc.). Space usage is handled by a separate command.
- **Secret Protection**: Never read or emit values from `.env*` files, tokens, or credentials — report variable **names only**.

## Workflow Steps

### Step 1: Collect Environment & Hardware Snapshot

Execute the bundled collector script [collect-env-info.sh](./scripts/collect-env-info.sh) (resolved relative to this `SKILL.md` directory) passing the active workspace directory:

```bash
<skill-dir>/scripts/collect-env-info.sh "$(pwd)"
```

### Step 2: Present Structured Summary

Format the script output into concise, scannable Markdown sections:

1. **Hardware Specifications** — Manufacturer/vendor, model/product, chassis/virtualization, CPU (architecture, vendor, model, cores/threads), RAM & swap, and GPU/accelerators.
2. **OS & Host** — Hostname, OS version, kernel, uptime.
3. **Workspace & Services** — Working directory, git status (if applicable), project dev services (`dev.sh`), and notable running system services.
4. **Runtimes & Developer Tools** — Compact table showing installed tools with versions/paths, and briefly noting key missing tools (e.g., `node`, `docker`).
5. **Environment Configuration (Keys Only)** — List detected `.env*` files and their key names only (values redacted).
