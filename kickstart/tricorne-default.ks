# SPDX-FileCopyrightText: 2026 Thread & Signal LLC
# SPDX-License-Identifier: MIT
#
# tricorne-default.ks — minimal bootable Tricorne Live ISO.
#
# Produces a live-media image with:
#   - Fedora Workstation base (GNOME)
#   - Tricorne COPR enabled
#   - tricorne-default metapackage installed (reasonable daily-driver subset)
#   - tricorne_t SELinux policy active
#   - SELinux ENFORCING (non-negotiable, per CLAUDE.md §3.2)
#
# Build on a Fedora host with livemedia-creator:
#
#   livemedia-creator \
#     --make-iso \
#     --iso-only \
#     --iso-name="tricorne-default-f${RELEASEVER}-$(date +%Y%m%d).iso" \
#     --ks=kickstart/tricorne-default.ks \
#     --project="Tricorne" \
#     --releasever=${RELEASEVER}
#
# STATUS: Draft. Not yet validated — a Fedora host is required to
#         produce an ISO. See known gaps at the bottom.

# --- Base -------------------------------------------------------------
# Pull in Fedora Workstation Live as our base. We override package
# selection and post-install below.
%include fedora-live-workstation.ks

# --- Locale -----------------------------------------------------------
lang en_US.UTF-8
keyboard us
timezone --utc UTC

# --- Authentication ---------------------------------------------------
# Live ISO: root locked; live user is unprivileged and uses sudo.
rootpw --lock
user --name=liveuser --groups=wheel --password="" --plaintext

# --- SELinux ----------------------------------------------------------
# NON-NEGOTIABLE. Do not change to permissive or disabled for "convenience."
# See CLAUDE.md §3.2.
selinux --enforcing

# --- Firewall ---------------------------------------------------------
# Live environment: permissive by default (the operator runs tests
# from the live session). Installed workstations should reconfigure
# via `firewall-cmd` after first boot.
firewall --disabled

# --- Repos ------------------------------------------------------------
# Fedora's standard repos come from the included base kickstart.
#
# Tricorne COPR — where our packaged tools live.
repo --name=tricorne-default \
     --baseurl=https://download.copr.fedorainfracloud.org/results/@tricorne/default/fedora-$releasever-$basearch/

# RPM Fusion for tools with legal-but-non-free components (codecs for
# forensics tooling, some wireless firmware). Standard Fedora practice.
repo --name=rpmfusion-free \
     --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-$releasever&arch=$basearch
repo --name=rpmfusion-nonfree \
     --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-$releasever&arch=$basearch

# --- Packages ---------------------------------------------------------

%packages
# Inherit the Workstation Live package set.
@^workstation-product-environment

# Tricorne daily-driver metapackage.
tricorne-default

# Foundational Blue Corner.
tricorne-selinux-policy
tricorne-audit-rules

# Purple Corner CLI.
tricorne-engage
tricorne-report

# Branding.
tricorne-artwork

# Shell defaults (see DESIGN.md §7.4).
zsh
tmux
fish

# Explicitly exclude packages that would undermine SELinux posture.
-setools-console

%end

# --- Post-install -----------------------------------------------------

%post --log=/var/log/tricorne-kickstart.log
echo "[tricorne] post-install begin"

# Re-assert SELinux enforcing. Redundant with `selinux --enforcing`
# above but cheap to double-check. Never remove this block.
if ! command -v getenforce >/dev/null 2>&1 ; then
    echo "[tricorne] ERROR: SELinux userspace not installed. Aborting."
    exit 1
fi
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=targeted/' /etc/selinux/config

# Drop a /etc/os-release override so boot banners and tooling can
# detect that this is Tricorne.
cat >> /etc/os-release <<EOF
VARIANT="Tricorne"
VARIANT_ID=tricorne
TRICORNE_VERSION="0.1.0-pre"
EOF

# Set zsh as the default shell for liveuser, if zsh is installed.
if [ -x /usr/bin/zsh ] && id liveuser >/dev/null 2>&1 ; then
    chsh -s /usr/bin/zsh liveuser
fi

# Enable auditd — Blue Corner default.
systemctl enable auditd.service

# Load Tricorne audit rules if the package is present.
if [ -d /usr/share/tricorne/audit ] ; then
    cp /usr/share/tricorne/audit/*.rules /etc/audit/rules.d/ 2>/dev/null || :
    augenrules --load 2>/dev/null || :
fi

echo "[tricorne] post-install complete"
%end

# --- Known gaps / TODO ------------------------------------------------
#
# - `tricorne-default`, `tricorne-selinux-policy`, `tricorne-engage`,
#   `tricorne-report`, `tricorne-audit-rules`, and `tricorne-artwork`
#   are metapackages that do not yet exist. A Fedora-host maintainer
#   will need to either (a) build them first into a local mock repo
#   referenced by the kickstart, or (b) comment out their lines until
#   they exist in COPR.
#
# - This kickstart has not been run through `livemedia-creator`.
#   Expected validation path: build on a Fedora VM, boot the ISO in
#   QEMU, verify SELinux is enforcing (`getenforce`), verify the
#   tricorne_t domain loads (`semodule -l | grep tricorne`), verify
#   `tricorne-engage --help` returns something sane.
#
# - `%include fedora-live-workstation.ks` assumes the stock Fedora
#   workstation kickstart is available to the build tooling. On hosts
#   where it isn't, either reference it by absolute path or convert
#   this file to not use %include and set the install source
#   directly.
