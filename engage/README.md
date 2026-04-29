<!--
SPDX-FileCopyrightText: 2026 Thread & Signal LLC
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# engage/

Original **Purple Corner** tooling. See `DESIGN.md` §7.2 and
`CLAUDE.md` §4.4.

## Subdirectories (planned)

- `tricorne-engage/` — the main engagement CLI (`new`, `scope`, `log`,
  `capture`, `seal`, `report`)
- `tricorne-report/` — report generator that consumes sealed
  engagement workspaces
- `scope-parsers/` — shared scope-file parsers used by wrapper scripts
  around `nmap`, `masscan`, `ffuf`, `nuclei`

## Language

Per `CLAUDE.md` §4.4, in order of preference:

1. **Python** — `typer` for CLI, `pydantic` for data models, `rich`
   for output.
2. **Rust** — when speed, long runs, or aggressive filesystem work
   justifies it. `clap` + `serde` + `tokio`.
3. **Shell** — glue only, under ~30 lines.

## License

All original code in `engage/` is **Apache-2.0** (for the patent
grant). Do not use GPL-3.0 or AGPL-3.0. See `DESIGN.md` §11.

## Contract

All Purple Corner tooling must:

- Refuse to run outside a `tricorne_engagement_t` context
  (or warn loudly in `--dev` mode).
- Log every action to the engagement log in structured JSON.
- Fail closed on scope violations. Override flags must be explicit
  (`--force-out-of-scope`) and always logged.

## Status

Empty. The v0.1 MVP (`tricorne-engage` with `new`, `scope`, `seal`)
is `CLAUDE.md` §6 priority 6 and the next thing in the pipeline.
Design choices (scope file schema, engagement log format, sealing
semantics) get made with Charles, not unilaterally.
