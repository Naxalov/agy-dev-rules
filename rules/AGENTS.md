# Antigravity Development Rules

General development guidelines, safety guardrails, and coding conventions enforced while this plugin is active.

## 1. Planning & Proposal Workflow
Before implementing any changes, always provide a proposal and short explanation scaled to the change scope:
- **Tier 1: Cosmetic & Micro (Tweaks, Formatting, Typos, Minor Chores)**: 1–2 sentence statement specifying target file, change, and reasoning.
- **Tier 2: Bug Fixes & Edge Cases (Patches, Regressions, Exception Handling)**: Identify root cause, trigger condition, and fix strategy.
- **Tier 3: Enhancements & Refactoring (Minor Features, Restructuring, Dependency Updates)**: Outline proposed approach, affected files, and verify existing contracts remain intact.
- **Tier 4: Major Features & High-Risk Changes (New Modules, Breaking Changes, Migrations, Security)**: Detailed plan covering architecture, step-by-step implementation, risk mitigation, and verification.

> Reference: For full change categorization and taxonomy, see `docs/CHANGE_TAXONOMY.md`.

## 2. Safety & File Handling
- **Preserve Documentation Integrity**: Always preserve existing comments, docstrings, and type annotations unrelated to your modifications.
- **Atomic Operations**: Make atomic, targeted edits rather than sweeping unstructured replacements.
- **Secret Protection**: Never commit or emit API keys, private tokens, or sensitive credentials into git-tracked files.

## 3. Architecture & Design Principles
- **Progressive Disclosure**: Encapsulate procedural runbooks into dedicated skills under `skills/<skill_name>/SKILL.md`. Keep the primary `SKILL.md` concise and place extensive manuals in `references/`.
- **Namespaced MCP Tools**: When exposing MCP servers, prefix server and tool identifiers with `agy-dev-rules-` to prevent collisions across the global namespace.
- **Hook Idempotence**: Keep lifecycle hooks fast and non-blocking. Scripts must cleanly handle unexpected inputs and return valid JSON to `stdout`.

## 4. Code Standards & Verification
- **Shell Scripts**: Ensure all bash/sh scripts use `set -euo pipefail` and include execution permissions (`chmod +x`).
- **Validation**: Test plugins with `agy plugin validate . --strict` before submitting changes or publishing.

