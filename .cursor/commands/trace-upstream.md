# Upstream-first debugging (ServePoint)

Apply this mindset to the problem or code in context:

1. **Trace upstream** — Find where the bad assumption lives (config, schema, column names, types, env) before changing application code. The symptom is rarely where the bug is introduced.

2. **Smallest fix** — Prefer the fewest lines that correct the actual cause. Do not add helpers, wrappers, or new modules to work around a wrong type, name, or migration.

3. **Database / ORM** — Confirm what Postgres actually has (e.g. `\d table`, `information_schema`) and align migrations and ORM `column=` with that. Do not guess quoted vs lowercase identifiers.

4. **Stop when fixed** — Do not refactor unrelated code, expand scope, or add “nice to have” behavior in the same change unless asked.

5. **If unsure** — Inspect or ask one targeted question; do not ship a pile of alternatives.

Project rules: `.cursor/rules/upstream-first-debugging.mdc` (authoritative), `.cursor/rules/slash-commands.mdc` (all slash commands ↔ rules).
