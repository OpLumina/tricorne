<!--
SPDX-FileCopyrightText: 2026 Thread & Signal LLC
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# packaging/nmap/

| Field             | Value                                                   |
|-------------------|---------------------------------------------------------|
| Package name      | `tricorne-nmap`                                         |
| Upstream tool     | [nmap](https://nmap.org/)                               |
| Fedora package    | [nmap](https://packages.fedoraproject.org/pkgs/nmap/)   |
| Tier              | 1 (native RPM) — SELinux integration overlay            |
| Maintainer        | Charles Russella <crussella0129@gmail.com>              |
| SELinux module    | [`selinux/nmap/`](../../selinux/nmap/) *(forthcoming)*  |

## Why this package exists

`nmap` is already packaged in Fedora proper. Per `CLAUDE.md` §3.1
("Upstream First, Always"), **we do not repackage it.** Tricorne depends
on the Fedora `nmap` package for the binary.

What this directory ships is `tricorne-nmap`: a small wrapper package
that installs the Tricorne-authored SELinux policy module for nmap
(from `selinux/nmap/`, forthcoming) and sets the policy booleans that
let nmap run the way operators need.

This is the actual Tricorne value-add for nmap — the **Blue Corner**
piece that no other offensive distribution provides.

## What this package installs

- `/usr/share/selinux/packages/nmap_tricorne.pp` — compiled SELinux
  policy module
- `/usr/share/doc/tricorne-nmap/policy-threat-model.md` — threat model
  for this policy (copy of `selinux/nmap/README.md`)
- `%post` scriptlet runs `semodule -i` to load the module and
  `restorecon` to relabel the nmap binary with `tricorne_exec_t` so
  the domain transition fires

No binaries. No Ruby. No Go. No vendored source.

## Directory / file naming pattern

This directory establishes Tricorne's packaging convention for tools
that are already in Fedora:

```
packaging/
└── nmap/                         # directory named for the upstream tool
    ├── tricorne-nmap.spec         # spec named for the RPM we produce
    ├── README.md                  # this file — rationale, status, pattern
    └── sources/                   # upstream tarballs (gitignored)
```

For tools **not** in Fedora, the same directory layout applies but
the spec file gains full `%prep` / `%build` / `%install` phases that
build the upstream source. For tools **already** in Fedora, we only
ship the SELinux overlay and any Tricorne-specific configuration.

The spec filename matches the `Name:` tag, which is what `rpmlint`
expects. The directory name matches the upstream tool, which is what
humans expect.

## Relationship to `CLAUDE.md` §6 priority 2

`CLAUDE.md` §6 lists `packaging/nmap/` as priority 2:
*"first tool, establishes the packaging pattern."* This directory
serves that purpose. The pattern it establishes:

1. `packaging/<tool>/` grouping directory
2. `<PackageName>.spec` with SPDX header, proper `License:` tag, and
   explicit `BuildRequires` / `Requires` / `Requires(post)`
3. `README.md` documenting upstream URL, Fedora status, rationale,
   maintainer, and build notes
4. `sources/` holding upstream tarballs (gitignored per
   `.gitignore`)
5. Companion SELinux module at `selinux/<tool>/` with its own
   `README.md` and threat model
6. Companion entry in `metapackages/` declaring which metapackage(s)
   pull this in

## How to build

From a Fedora host with `rpm-build` and `mock` installed, from the
repo root:

```bash
# Create a source tarball from the current tree
tar czf ~/rpmbuild/SOURCES/tricorne-0.1.0.tar.gz \
    --transform 's,^,tricorne-0.1.0/,' \
    selinux/ LICENSES/ packaging/nmap/README.md

# Lint the spec
rpmlint packaging/nmap/tricorne-nmap.spec

# Build in a clean Fedora chroot
mock --rebuild --spec=packaging/nmap/tricorne-nmap.spec \
     --sources=packaging/nmap/sources/

# Optional: full Fedora package review
fedora-review -n tricorne-nmap
```

All three should pass cleanly before merge to `main`.

## Status

**Draft — not validated on Fedora.**

This spec was authored on a Windows workstation and has not been run
through `mock`, `rpmlint`, or `fedora-review`. Before first release, a
maintainer with a Fedora environment must:

1. `rpmlint tricorne-nmap.spec` — fix all errors and warnings
2. `mock --rebuild` — confirm the build succeeds in a clean chroot
3. `fedora-review` — confirm guideline compliance
4. Install the built RPM in a Fedora VM, run nmap under `tricorne_t`,
   verify no unexpected AVCs via `ausearch -m avc -ts recent`

Until all four pass, do not cut a tagged release.
