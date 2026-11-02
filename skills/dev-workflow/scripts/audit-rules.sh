#!/usr/bin/env bash
set -euo pipefail

echo "==> Running Antigravity workspace audit..."

# Check required files
for file in plugin.json rules/AGENTS.md assets/logo.svg; do
  if [[ -f "$file" ]]; then
    echo "  [OK] Found $file"
  else
    echo "  [WARN] Missing $file"
  fi
done

# Check executable permissions on scripts
find scripts -type f -name "*.sh" -exec test -x {} \; -exec echo "  [OK] Executable: {}" \;

echo "==> Audit complete."

