---
name: dev-workflow
description: Standard development and audit workflow for Antigravity rules and extensions. Use when verifying project guidelines, auditing repo health, or onboarding new workflows.
---

# Antigravity Dev Workflow

Step-by-step operating runbook for validating codebase structure, verifying rules compliance, and inspecting active customizations.

## Prerequisites

- Antigravity CLI (`agy`) installed and available in the current `$PATH`.
- Bash-compatible shell environment.

## Workflow Steps

### Step 1: Run Project Rules Audit
Execute the workspace audit script to check for common misconfigurations:
```bash
./scripts/audit-rules.sh
```

### Step 2: Validate Plugin Integrity
Run the built-in Antigravity plugin validator:
```bash
agy plugin validate . --strict
```

### Step 3: Verify Tool and Hook Contracts
Confirm that all hook scripts execute with exit code 0 and return valid protojson structures:
```bash
echo '{"toolCall":{"name":"run_command","args":{"CommandLine":"ls -la"}}}' | ./scripts/pre-tool-check.sh
```

