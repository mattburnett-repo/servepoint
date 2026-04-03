# Pre-deploy code sweep (ServePoint)

Run a focused pre-deploy sweep for the current branch.

## Goals

1. Catch release blockers (runtime errors, broken routes, bad env assumptions, schema/ORM mismatches).
2. Confirm changed behavior is covered by tests and docs.
3. Keep fixes minimal and upstream-first.

## Sweep steps

1. **Branch delta**
   - List changed files (`git status --short`, `git diff --stat`).
   - Group changes by risk area: app bootstrap/config, handlers/services, DB/ORM, tests, docs.

2. **Upstream checks first**
   - Verify env/config assumptions in `Application.cfc`, `config/Coldbox.cfc`, and `docker/docker-compose.yml`.
   - Check `.env.example` only for variable coverage: it must include every environment variable required by the app (including new vars added elsewhere).
   - Do not perform any other `.env.example` checks in this sweep (no value/default/sample validation).
   - For DB-touching changes, verify ORM mappings/migrations align (names/types/case).

3. **Behavior checks**
   - Inspect changed handlers/services for guardrails, redirects, and error handling.
   - Flag risky assertions that may hide failures (for example asserting fallback behavior instead of intended route).

4. **Quality gates**
   - Run lints on changed files.
   - Run targeted tests for touched features first.
   - Run one consolidated full integration sweep in a single command after targeted runs:
     - `curl -sS "http://localhost:8081/tests/index.cfm?action=runTestBox&path=specs/integration"`
   - Keep this command fast by default: use the current running app/container unless the user explicitly asks for a clean rebuild.
   - Optional (only when requested): clean rebuild + fresh DB state
     - `docker compose --env-file .env.dev -f docker/docker-compose.yml down`
     - `rm -rf .db/postgres/data`
     - `docker compose --env-file .env.dev -f docker/docker-compose.yml up --build`
   - For each test command, include execution evidence in the report (command, pass/fail, and key output or blocker).
   - If tests cannot be executed (environment/sandbox/runtime issue), do not mark quality gates complete; capture the exact blocker under **Open risks** and provide the exact command to run once unblocked.

5. **Docs/sync checks**
   - If behavior/config changed, verify `README.md`, `DEV_NOTES.md`, and relevant `design/mermaid/*.md` are updated.

## Output format

Return results in this order:

1. **Findings** (highest severity first) with file paths.
2. **Passes** (what is verified clean).
3. **Open risks** (what was not fully verified and why).
   - Explicitly call out when targeted tests passed but the single consolidated integration sweep was not run.
   - If no test execution evidence is present, this must be listed as an open risk (not a pass).
4. **Minimal next actions** (exact commands or tiny fixes).

## Constraints

- Follow upstream-first debugging.
- Prefer the smallest fix that corrects the root cause.
- Do not broaden scope beyond deploy readiness unless asked.

Project rules: `.cursor/rules/outcome-minimal-steps-framing.mdc`, `.cursor/rules/upstream-first-debugging.mdc`, `.cursor/rules/slash-commands.mdc`.
