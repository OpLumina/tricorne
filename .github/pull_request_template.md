<!--
SPDX-FileCopyrightText: 2026 Thread & Signal LLC
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## What

<!-- One-sentence summary of the change. -->

## Why

<!-- The problem being solved or capability being added.
     Link the issue this PR closes if applicable. -->

## Test plan

<!--
  How did you verify this works?
    - Packaging PRs: attach rpmlint output and mock build success.
    - Policy PRs: attach `ausearch -m avc -ts recent` from a real test run.
    - Code PRs: new tests + passing-run evidence.
    - Docs-only PRs: explain why; no test evidence needed.
-->

## Upstream links

<!-- For packaging PRs: upstream project URL, Fedora package status,
     any related Fedora Bugzilla or src.fedoraproject.org entries. -->

## Checklist

- [ ] I have read [`CONTRIBUTING.md`](../CONTRIBUTING.md)
- [ ] Commits are signed off (`git commit -s`) per DCO
- [ ] New/modified files carry SPDX headers
- [ ] `reuse lint` passes locally (if applicable)
- [ ] `rpmlint` passes for touched spec files (if applicable)
- [ ] SELinux policy compiles cleanly (if applicable)
- [ ] CI is green
- [ ] No secrets, credentials, engagement artifacts, or original exploits introduced
