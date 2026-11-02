# Antigravity Development Rules

General development guidelines, safety guardrails, and coding conventions enforced while this plugin is active.

## 1. Safety & File Handling
- **Preserve Documentation Integrity**: Always preserve existing comments, docstrings, and type annotations unrelated to your modifications.
- **Atomic Operations**: Make atomic, targeted edits rather than sweeping unstructured replacements.
- **Secret Protection**: Never commit or emit API keys, private tokens, or sensitive credentials into git-tracked files.

## 2. Architecture & Design Principles
- **Progressive Disclosure**: Encapsulate procedural runbooks into dedicated skills under `skills/<skill_name>/SKILL.md`. Keep the primary `SKILL.md` concise and place extensive manuals in `references/`.
- **Namespaced MCP Tools**: When exposing MCP servers, prefix server and tool identifiers with `agy-dev-rules-` to prevent collisions across the global namespace.
- **Hook Idempotence**: Keep lifecycle hooks fast and non-blocking. Scripts must cleanly handle unexpected inputs and return valid JSON to `stdout`.

## 3. Code Standards & Verification
- **Shell Scripts**: Ensure all bash/sh scripts use `set -euo pipefail` and include execution permissions (`chmod +x`).
- **Validation**: Test plugins with `agy plugin validate . --strict` before submitting changes or publishing.

