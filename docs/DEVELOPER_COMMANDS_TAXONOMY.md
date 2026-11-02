# Developer Commands & Lifecycle Taxonomy

A comprehensive reference guide for classifying and naming repetitive developer tasks, commands, and inner dev-loop scripts.

> **Note**: This document is intended for human reference, task naming, and project documentation. It is stored in `docs/` and is not loaded into the active runtime prompt context of AI agents.

---

## 1. Core Terminology

In software engineering, these commands fall into three formal disciplines:

1. **The "Inner Dev Loop"**: The high-frequency development cycle executed continuously while coding: `code` $\rightarrow$ `test` $\rightarrow$ `run` $\rightarrow$ `reset`.
2. **Task Runners / Lifecycle Scripts**: Standard entry points defined in `package.json` (`scripts`), `Makefile`, `Justfile`, `Taskfile.yml`, or `pyproject.toml`.
3. **Environment Sanitization & Process Bouncing**: Routines that clear stale runtime state, kill hung background processes, and restart daemons cleanly.

---

## 2. Command Categories & Reference Matrix

### A. Test & Verification Runners
*Commands executed repeatedly to confirm correctness after source changes.*

| Official Name | Description | Common Command Examples |
| :--- | :--- | :--- |
| **Unit Test Runner** | Runs fast, isolated test cases on functions and classes. | `npm test`, `pytest`, `cargo test`, `go test ./...` |
| **Watch Mode Runner** | File-watching runner that re-executes tests automatically on save. | `jest --watch`, `pytest -f`, `cargo watch -x test` |
| **Targeted Test Runner** | Executes a single test file, module, or test pattern. | `npm test -- -t "auth"`, `pytest tests/test_login.py -k test_jwt` |
| **Integration / E2E Suite** | Validates inter-service communication or browser flows. | `playwright test`, `cypress run`, `pytest -m integration` |
| **Coverage Reporter** | Measures code execution coverage percentage. | `pytest --cov`, `nyc npm test`, `cargo tarpaulin` |

---

### B. Process & Server Lifecycle (Start / Stop / Restart)
*Commands used to control long-running background processes and dev servers.*

| Official Name | Description | Common Command Examples |
| :--- | :--- | :--- |
| **Dev Server Startup** | Launches local development server with hot-module reloading. | `npm run dev`, `uvicorn main:app --reload`, `flask run` |
| **Process Bouncing (Hard Restart)** | Gracefully terminates and relaunches a hung or modified server. | `pm2 restart all`, `systemctl restart <app>`, `kill -HUP <pid>` |
| **Port Hunter & Clearance** | Identifies and terminates processes holding ports hostage (e.g., 3000, 8080). | `lsof -ti :3000 \| xargs kill -9`, `fuser -k 8080/tcp` |
| **Health Check Probe** | Pings endpoints to verify readiness after a restart. | `curl -f http://localhost:8080/healthz`, `wget -qO- :3000/api/ping` |
| **Hot Reload Daemon** | Process watcher that re-compiles or restarts on file change. | `nodemon`, `air` (Go), `cargo watch -x run`, `watchmedo` |

---

### C. State Sanitization & Environment Resets
*The "nuke and pave" routines run when caches, packages, or containers get corrupted.*

| Official Name | Description | Common Command Examples |
| :--- | :--- | :--- |
| **Cache Busting / Purge** | Deletes compiler, bundler, and test cache artifacts. | `rm -rf .next .turbo .pytest_cache __pycache__ dist/ target/` |
| **Clean Dependency Reinstall** | Removes lock-drifted modules and performs clean reinstall. | `rm -rf node_modules && npm ci`, `poetry install --sync` |
| **Stack / Container Recycle** | Tears down Docker containers, volumes, and recreates the stack. | `docker compose down -v && docker compose up -d --build` |
| **Dangling Resource Pruning** | Cleans up stopped containers, anonymous volumes, and dangling images. | `docker system prune -f`, `docker container prune` |
| **Working Tree Sanitization** | Discards unstaged modifications and un-tracked scratch files. | `git restore . && git clean -fd` |

---

### D. Database & Fixture Lifecycle
*Commands used to keep database schemas and mock data in a predictable state.*

| Official Name | Description | Common Command Examples |
| :--- | :--- | :--- |
| **Schema Migration** | Applies incremental database DDL scripts forward. | `alembic upgrade head`, `npx prisma migrate dev`, `rails db:migrate` |
| **Database Teardown & Reset** | Drops all tables/databases and re-runs migrations from scratch. | `npx prisma migrate reset`, `rails db:reset`, `flask db downgrade` |
| **Seed / Fixture Population** | Injects mock users, dummy entities, and catalog data for testing. | `npm run seed`, `python manage.py loaddata fixtures.json` |

---

### E. Static Analysis & Code Hygiene
*Commands run continuously to prevent syntax, type, and style degradation.*

| Official Name | Description | Common Command Examples |
| :--- | :--- | :--- |
| **Type Checking** | Static type analysis without emitting compiled JS/bytecode. | `npx tsc --noEmit`, `mypy .`, `pyright` |
| **Linter Pass** | Checks for code smells, unused variables, and anti-patterns. | `eslint .`, `ruff check .`, `flake8`, `cargo clippy` |
| **Formatter Pass** | Automatically formats spacing, quotes, and layout according to style rules. | `prettier --write .`, `black .`, `ruff format .`, `cargo fmt` |
| **Security Audit** | Scans dependency trees for vulnerabilities and CVE advisories. | `npm audit`, `pip-audit`, `cargo audit` |

---

### F. Antigravity Plugin Lifecycle
*Commands specific to development and verification of Antigravity plugins and agents.*

| Official Name | Description | Command |
| :--- | :--- | :--- |
| **Plugin Strict Validation** | Inspects manifests, hooks, logo dimensions, and file paths. | `agy plugin validate . --strict` |
| **Plugin Hot Re-install** | Replaces the active installed plugin copy with local edits. | `agy plugin install .` |
| **Hook Pre-flight Verification** | Tests hook scripts against mock protojson payloads via stdin. | `echo '{...}' \| ./scripts/pre-tool-check.sh` |
| **Workspace Rule Audit** | Runs repo-level audit script to check rule and script conformity. | `./skills/dev-workflow/scripts/audit-rules.sh` |
