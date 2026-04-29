<!--
SPDX-FileCopyrightText: 2026 Thread & Signal LLC
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# docs/

User-facing documentation for Tricorne, to be published as a static
site (mkdocs or Antora — TBD; Antora is closer to how Fedora publishes
its docs, mkdocs is simpler).

Separate from repo-root documentation (`README.md`, `CONTRIBUTING.md`,
`DESIGN.md`, etc.), which is for contributors and project management.

## Planned structure

- **Installation** — from COPR, from ISO, from toolbx
- **Engagement workflow** — using `tricorne-engage` end-to-end
- **SELinux cheatsheet** — booleans, common denials, how to add
  allow-rules without going permissive
- **Tool guides** — per-tool notes where Tricorne's integration
  differs from upstream (`hashcat` with GPU drivers, `metasploit`
  with native RPM, `ghidra` via Flatpak, etc.)
- **Upstream contribution guide** — how to push policy modules back
  to Fedora `selinux-policy`, how to push packaging improvements
  back to Fedora dist-git

## License

All content here is **CC-BY-SA-4.0**. See [`../LICENSE`](../LICENSE).

## Status

Empty. User docs land with the v0.1 public launch
(`CLAUDE.md` §6 priority 7).
