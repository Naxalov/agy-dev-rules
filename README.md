# Antigravity Dev Rules Plugin (`agy-dev-rules`)

A comprehensive Antigravity plugin providing development rules, procedural skills, custom subagents, lifecycle hooks, and validation tooling.

---

## 📦 Installation

You can install this plugin globally across all sessions, scope it to a specific workspace, or reference it via Git.

### Option 1: Direct Install from GitHub (One-Liner)

You do **not** need to manually clone or manage temporary directories. Antigravity CLI can install directly from a remote Git URL:

```bash
# HTTPS (Recommended)
agy plugin install https://github.com/Naxalov/agy-dev-rules

# Or via SSH
agy plugin install git@github.com:Naxalov/agy-dev-rules.git
```

The CLI automatically fetches the repository into a secure sandbox, validates all manifests and components, installs it into `~/.gemini/config/plugins/agy-dev-rules`, and cleans up all temporary artifacts.

> **Note**: For local development or installing from an existing clone:
> ```bash
> cd agy-dev-rules
> agy plugin install .
> ```

---

### Option 2: Project-Scoped Install via Git Submodule (Recommended for Teams)

To share these rules and skills across your team without requiring individual global installs, add it directly to your project's `.agents/` customization directory:

```bash
# In the root of your project repository:
git submodule add https://github.com/Naxalov/agy-dev-rules.git .agents/plugins/agy-dev-rules
```

Antigravity automatically discovers all plugins located inside `.agents/plugins/` on session start.

---

### Option 3: Shared Registration via `plugins.json`

If the repository is cloned elsewhere on your machine or shared in a monorepo, register its path in your workspace's `.agents/plugins.json` (or global `~/.gemini/config/plugins.json`):

```json
{
  "entries": [
    {
      "path": "path/to/agy-dev-rules"
    }
  ]
}
```

---

### Option 4: Antigravity Agent Marketplace

Once published to a public or organization catalog, install directly by name:

```bash
# Install from default marketplace
agy plugin install agy-dev-rules

# Install from a specific marketplace namespace
agy plugin install agy-dev-rules@<marketplace-id>
```

Or open the in-app **Customizations** UI:
1. Navigate to **Settings > Customizations > Marketplace**.
2. Search for **Antigravity Dev Rules** (`agy-dev-rules`).
3. Click **Install** and restart the session.

---

## ⚙️ Plugin Management

Inspect and control plugin status using the `agy` CLI:

```bash
# Check installed plugins and status
agy plugin list

# Enable or disable live without restarting
agy plugin enable agy-dev-rules
agy plugin disable agy-dev-rules

# Validate files and schema under strict mode
agy plugin validate . --strict

# Uninstall the plugin
agy plugin uninstall agy-dev-rules
```

---

## 📁 Directory Structure

```text
agy-dev-rules/
├── plugin.json                 # Core plugin manifest (JSONC)
├── README.md                   # Plugin documentation
├── docs/                       # Human reference guides (not loaded into AI runtime context)
│   └── CHANGE_TAXONOMY.md      # Comprehensive software change classification guide
├── assets/
│   └── logo.svg                # Plugin icon (min 128x128, transparent)
├── rules/
│   └── AGENTS.md               # Continuous rules enforced while plugin is active
├── skills/
│   └── dev-workflow/           # Procedural skill with slash command /dev-workflow
│       ├── SKILL.md            # Skill instructions with YAML frontmatter
│       └── scripts/            # Helper scripts
│           └── audit-rules.sh
├── agents/
│   └── rules-auditor.md        # Dedicated subagent definition
├── mcp_config.json             # MCP server definitions (Stdio / Streamable HTTP)
├── hooks.json                  # Lifecycle hooks (must be placed at plugin root)
├── scripts/                    # Shared helper and hook scripts
│   ├── pre-tool-check.sh
│   ├── mcp-server.js
│   └── watcher.sh
└── sidecars/
    └── rules-watcher/          # Background daemon / UI sidecar
        └── sidecar.json
```

---

## 🚀 Quick Start & Verification

### 1. Validate Plugin Structure
Run strict validation to check all manifests, files, and hook paths:
```bash
agy plugin validate . --strict
```

### 2. Verify Hook Handlers
Test the `PreToolUse` hook pipeline:
```bash
echo '{"toolCall":{"name":"run_command","args":{"CommandLine":"npm test"}}}' | ./scripts/pre-tool-check.sh
```

### 3. Run the Development Audit Workflow
Invoke the procedural audit:
```bash
./skills/dev-workflow/scripts/audit-rules.sh
```

---

## 🧩 Components Overview

- **Manifest (`plugin.json`)**: Configures display name, suggested prompts, and metadata.
- **Documentation (`docs/`)**: Human-facing guides and taxonomies excluded from runtime agent prompt budgets.
- **Skills (`skills/dev-workflow/`)**: Teaches the agent standard operating procedures.
- **Rules (`rules/AGENTS.md`)**: Enforces style and safety guardrails across turns.
- **Subagents (`agents/rules-auditor.md`)**: Specialized worker for auditing conformity.
- **Hooks (`hooks.json`)**: Intercepts tool calls before execution.
- **MCP (`mcp_config.json`)**: Integrates custom tools via standard protocol.
- **Sidecars (`sidecars/rules-watcher/`)**: Runs background workspace monitoring.
