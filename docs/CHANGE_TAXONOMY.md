# Comprehensive Software Change Taxonomy

A reference guide for classifying software modifications across the entire development lifecycle, from micro-tweaks to major architectural migrations.

> **Note**: This document is intended for human reference, team alignment, and documentation purposes. It is not loaded into the active runtime prompt context of AI agents.

---

## Change Classification Matrix

| Tier & Type | Software Engineering Term | Real-World Examples | Expected Proposal & Explanation Scope |
| :--- | :--- | :--- | :--- |
| **Tier 1: Cosmetic & Micro** | **Micro-Tweak / Nit** | Typo corrections, docstring/comment phrasing, minor styling adjustments, variable renaming. | **1 sentence**: Target file, exact replacement, and reasoning. |
| | **Code Formatting & Linting** | Prettier, ESLint, Black, or rustfmt passes; whitespace normalization; import sorting. | **1 sentence**: Tool and configuration rules being applied across target files. |
| **Tier 2: Defect Resolution** | **Hotfix / Patch** | Unhandled null pointers, memory leaks, process crashes, broken user-facing buttons. | **Short**: Root cause, error trace summary, and immediate fix approach. |
| | **Edge-Case Fix** | Boundary conditions (empty list, division by zero, timezone offset, unexpected input types). | **Short**: Unhandled edge case identified and fallback/guard mechanism introduced. |
| | **Regression Fix** | Correcting behavior broken by a recent update or dependency upgrade. | **Short**: What broke, which change caused it, and the corrective diff plan. |
| **Tier 3: Maintenance & Chores** | **Dependency Update** | Patch or minor version bumps in `package.json`, `requirements.txt`, `Cargo.toml`. | **Short**: List of updated packages, changelog highlights, and breaking change checks. |
| | **Configuration & Build (Chore)** | Updates to `.gitignore`, Dockerfiles, CI/CD pipelines, build tools, compiler flags. | **Medium**: Settings altered, environment impact, and verification steps. |
| | **Typing & Schema Validation** | Adding TypeScript types, JSDoc annotations, JSON schemas, runtime validation rules. | **Medium**: Type definitions added, schema models, and where validation is attached. |
| **Tier 4: Quality & Debt** | **Refactoring** | Restructuring internal logic to improve readability or reduce duplication without changing external behavior. | **Medium**: Target code smell, proposed abstraction, and proof of invariant external behavior. |
| | **Dead Code Retirement** | Removing unused functions, obsolete feature flags, dead branches, deprecated helpers. | **Medium**: List of symbols/files removed and verification of zero active references. |
| **Tier 5: Features & Enhancements** | **Minor Enhancement** | Adding an optional parameter, convenience utility, or extending existing function behavior. | **Medium**: Signature change, default value, and backward compatibility impact. |
| | **New Feature** | Introducing a brand-new user capability, API route, or UI screen. | **Structured Plan**: Feature requirements, file structure, API contract, and test plan. |
| | **Third-Party Integration** | Connecting an external API, SDK, webhook handler, or MCP server. | **Structured Plan**: Authentication flow, endpoint contract, error handling, and rate limits. |
| **Tier 6: Hardening & Performance** | **Performance Optimization** | Algorithmic improvement (e.g., $O(n^2)$ to $O(n \log n)$), query indexing, caching, memoization. | **Structured Plan**: Current bottleneck, benchmark/metric targeted, and optimization logic. |
| | **Security Remediation** | Patching CVEs, input sanitization, CSRF/XSS prevention, secret management hardening. | **Structured Plan**: Vulnerability severity, exploit vector, and defense-in-depth mitigation. |
| **Tier 7: High-Risk & Architectural** | **Data & Schema Migration** | Database column additions/drops, state schema transforms, data backfills. | **Detailed Plan**: Forward/rollback migration steps and data loss prevention safeguards. |
| | **Breaking Change (Major)** | Modifying public API signatures, removing endpoints, major upgrades. | **Detailed Plan**: Breaking impact assessment, migration/deprecation path, and client compatibility. |
| | **Architectural Overhaul** | Rewriting subsystems, switching frameworks, modularizing monorepos. | **Full Proposal**: Architecture diagram/spec, phased rollout milestones, risks, and verification criteria. |

---

## Operational Summary (4-Tier AI Agent Model)

For autonomous agents and automated workflows, the 17 types above are consolidated into 4 operational tiers in [`rules/AGENTS.md`](../rules/AGENTS.md):

1. **Tier 1: Cosmetic & Micro**: 1–2 sentence statement of target edit and rationale.
2. **Tier 2: Bug Fixes & Edge Cases**: Root cause identification and targeted fix strategy.
3. **Tier 3: Enhancements & Refactoring**: Plan covering design, affected files, and contract stability.
4. **Tier 4: Major Features & High-Risk Changes**: Comprehensive proposal with architecture details, step-by-step implementation, risk mitigation, and verification checklist.

