<!--
SPDX-FileCopyrightText: 2026 Thread & Signal LLC
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# selinux/tricorne-base/ — SELinux base policy

This directory defines the `tricorne_t` domain and its supporting
types. It is the foundation every Red Corner tool's SELinux integration
builds on.

## Threat model

The `tricorne_t` domain is designed to answer a specific question:
**what capabilities does an operator's pentest toolchain genuinely
need, and where is the line beyond which a compromised tool becomes a
workstation compromise?**

Operator tools genuinely need:

- Raw sockets (`nmap` SYN scans, ARP probes, packet crafting)
- Promiscuous capture (`wireshark`, `bettercap`, `tcpdump`)
- Connect-anywhere network access
- Process introspection for legitimate red-team simulation
  (off by default, enabled per-engagement)
- Manage-anything access to the operator's engagement workspaces

Operator tools should **not** casually have:

- Access to `/etc/shadow`
- Access to `/root`
- Access to arbitrary home directories outside `~/engagements/`
- Access to other users' processes
- Rights over systemd service units
- Ability to load kernel modules
- DAC override

If a tool needs any of the second list, the need gets a justified,
documented exception — not blanket `unconfined_t`.

This policy grants the first list (narrowly, and boolean-gated for
the sensitive ones), denies the second list (by simply not granting
it — SELinux's default-deny posture does the work), and logs
everything so audit review catches surprises.

## Contents

| File            | Role                                                                            |
|-----------------|---------------------------------------------------------------------------------|
| `tricorne.te`   | Type enforcement: domain declaration, type declarations, allow rules, tunables  |
| `tricorne.fc`   | File contexts: which paths on disk carry tricorne types                         |
| `tricorne.if`   | Interfaces: macros other policy modules call (transitions, reads, manages)      |

## Booleans

| Boolean                       | Default | Effect                                                                  |
|-------------------------------|---------|-------------------------------------------------------------------------|
| `tricorne_raw_socket`         | `on`    | Raw IP sockets, packet sockets — needed for nmap and most recon tools   |
| `tricorne_promisc_capture`    | `on`    | Promiscuous mode on network interfaces — needed for capture tools       |
| `tricorne_proc_introspect`    | `off`   | ptrace of non-system user processes — off by default, enable per engagement |

A locked-down deployment can toggle off any of these without shifting
the domain to permissive. Example:

```bash
sudo setsebool -P tricorne_promisc_capture off
```

## Types

| Type                | Scope                                                    |
|---------------------|----------------------------------------------------------|
| `tricorne_t`        | Process domain for operator tools                        |
| `tricorne_exec_t`   | Executable type that triggers transition to `tricorne_t` |
| `tricorne_tmp_t`    | Scratch files under `/var/tmp/tricorne/`                 |
| `tricorne_home_t`   | Per-operator engagement workspaces under `~/engagements/`|

Additional per-engagement types (`tricorne_engagement_t`,
`tricorne_report_t`) are defined in separate modules — see
`selinux/tricorne-engagement/` (forthcoming) and
`selinux/tricorne-report/` (forthcoming).

## Build

On a Fedora system with `selinux-policy-devel` installed:

```bash
cd selinux/tricorne-base
make -f /usr/share/selinux/devel/Makefile
sudo semodule -i tricorne.pp
sudo restorecon -R /usr/bin/tricorne-shell /usr/bin/tricorne-engage
```

Verify:

```bash
# Module loaded?
semodule -l | grep tricorne

# Type assigned to the binaries?
ls -lZ /usr/bin/tricorne-shell

# Transition fires when the binary runs?
runcon -t user_t /usr/bin/tricorne-shell
# then in the child shell:
id -Z   # should show tricorne_t
```

## Testing

1. `sudo setenforce 1` — confirm enforcing. Per `CLAUDE.md` §3.2,
   this should be the system default.
2. Launch a tool via `tricorne-shell` or explicit
   `runcon -t tricorne_t <cmd>`.
3. Run the tool's normal workflow (for nmap: `nmap -sS 127.0.0.1`).
4. Collect denials: `sudo ausearch -m avc -ts recent`.
5. Iterate: add narrow allow rules, not blanket permissions. Prefer
   boolean-gated rules for anything that might reasonably be disabled
   in a locked-down deployment.
6. Re-compile, re-insert the module, re-test.

## Known gaps / TODO

- **Policy v0.0.1.** No real tool runs have produced AVC denials to
  incorporate yet.
- **Interface name verification.** The policy references
  `userdom_manage_user_home_content_*`, `corenet_tcp_connect_all_ports`,
  `sysnet_dns_name_resolve`, `logging_send_audit_msgs`, and
  `auth_dontaudit_read_shadow`. These are standard refpolicy interfaces
  but names have drifted over Fedora versions. Verify against the target
  Fedora's `/usr/share/selinux/devel/include/` before `make`.
- **Windows-authored.** This draft was written without access to a live
  Fedora system. Compile with `checkmodule` and `semodule_package` on
  Fedora before merging.

## Upstream submission

Per `CLAUDE.md` §6 priority 8 — *"One SELinux policy module submitted
to upstream `selinux-policy` — the credibility anchor"* — once this
module stabilizes (target v0.1), we submit it upstream. Target: a new
`pentest` or `tricorne` module in Fedora's `selinux-policy` package.
This is how Tricorne demonstrates it is a **net contributor** to
Fedora's security posture rather than a parasite.
