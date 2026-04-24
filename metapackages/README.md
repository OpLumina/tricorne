<!--
SPDX-FileCopyrightText: 2026 Thread & Signal LLC
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# metapackages/

RPM specs for the `tricorne-*` metapackages — the Red, Blue, and Purple
Corner groupings that pull collections of individual packages together.

Planned (per `DESIGN.md` §4.3):

- **Top-level:** `tricorne-default`, `tricorne-everything`
- **Red Corner:** `tricorne-web`, `tricorne-wireless`, `tricorne-network`,
  `tricorne-exploitation`, `tricorne-forensics`, `tricorne-reversing`,
  `tricorne-crypto`, `tricorne-osint`, `tricorne-cloud`, `tricorne-ad`,
  `tricorne-mobile`
- **Blue Corner:** `tricorne-selinux-policy`, `tricorne-audit-rules`,
  `tricorne-hardening`
- **Purple Corner:** `tricorne-engage`, `tricorne-report`

None implemented yet. First candidate for implementation once
`packaging/nmap/` and `selinux/tricorne-base/` are stable:
`tricorne-selinux-policy` (it has the clearest scope — pull in every
`tricorne-selinux(*)` provider).

## Structure

Each metapackage lives in its own subdirectory with a `.spec` file and
an optional `README.md`:

```
metapackages/
├── tricorne-default/
│   └── tricorne-default.spec
├── tricorne-web/
│   └── tricorne-web.spec
└── ...
```

Metapackage spec files contain only `Requires:` entries — no build,
no install — and produce a `noarch` RPM.

## License

Spec files and scriptlets here are **MIT**. See [`LICENSE`](../LICENSE).
