#!/usr/bin/env bash
set -euo pipefail

# Read stdin JSON payload
PAYLOAD=$(cat || echo "{}")

# Basic check (allow by default)
cat <<'EOF'
{
  "decision": "allow"
}
EOF

