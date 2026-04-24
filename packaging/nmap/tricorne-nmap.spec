# SPDX-FileCopyrightText: 2026 Thread & Signal LLC
# SPDX-License-Identifier: MIT
#
# tricorne-nmap: Tricorne SELinux integration for the Fedora nmap package.
#
# This package does NOT build nmap. It depends on the Fedora `nmap`
# package and ships the Tricorne-authored SELinux policy module that
# allows nmap to run inside the tricorne_t domain with narrowly-scoped
# elevated capabilities (raw sockets, packet sockets for SYN scans,
# ICMP generation) while remaining constrained from reading /etc/shadow,
# other users' homes, or system config.
#
# STATUS: Draft. Not yet validated against rpmlint or fedora-review.
#         Before first release, a maintainer with a Fedora environment
#         must run `rpmlint`, `fedpkg mockbuild`, and `fedora-review`
#         and fix every finding.

%global modulename nmap_tricorne

Name:           tricorne-nmap
Version:        0.1.0
Release:        1%{?dist}
Summary:        Tricorne SELinux integration for nmap

# The installed contents are the compiled SELinux policy module,
# licensed GPL-2.0-or-later to match upstream selinux-policy. The
# License: tag describes the RPM payload, not the spec file.
License:        GPL-2.0-or-later
URL:            https://github.com/crussella0129/tricorne
Source0:        https://github.com/crussella0129/tricorne/archive/v%{version}/tricorne-%{version}.tar.gz

BuildArch:      noarch

BuildRequires:  make
BuildRequires:  selinux-policy-devel

# Hard runtime dependencies.
Requires:       nmap
Requires:       selinux-policy-targeted

# Scriptlet dependencies. semodule lives in policycoreutils; the
# -python-utils package provides semanage for future boolean toggles.
Requires(post):     policycoreutils
Requires(post):     policycoreutils-python-utils
Requires(postun):   policycoreutils

# Declare ourselves as the SELinux integration for nmap, so a
# `tricorne-selinux-policy` metapackage can `Requires: tricorne-selinux(nmap)`.
Provides:       tricorne-selinux(nmap) = %{version}-%{release}

%description
tricorne-nmap installs Tricorne's SELinux policy module for the nmap
network scanner. The module defines transitions and grants that let
nmap operate inside the tricorne_t domain with the capabilities it
genuinely needs — raw IP sockets, packet sockets for SYN scans, ICMP
generation — while keeping the default-deny posture for everything
else (operator HOME outside engagements, /etc/shadow, system config).

This package does not bundle the nmap binary. It requires the nmap
package shipped by Fedora proper.

%prep
%autosetup -n tricorne-%{version}

%build
cd selinux/nmap
make -f /usr/share/selinux/devel/Makefile %{modulename}.pp

%install
install -D -m 0644 selinux/nmap/%{modulename}.pp \
    %{buildroot}%{_datadir}/selinux/packages/%{modulename}.pp
install -D -m 0644 selinux/nmap/README.md \
    %{buildroot}%{_docdir}/%{name}/policy-threat-model.md

%post
# On install (not upgrade), load the module and relabel the nmap binary
# so it carries the tricorne_exec_t context that triggers the transition.
if [ $1 -ge 1 ] ; then
    /usr/sbin/semodule -n -i %{_datadir}/selinux/packages/%{modulename}.pp
    if /usr/sbin/selinuxenabled ; then
        /usr/sbin/load_policy
        /sbin/restorecon -R %{_bindir}/nmap %{_bindir}/ncat 2>/dev/null || :
    fi
fi

%postun
# On uninstall (not upgrade), remove the module. $1 is the count of
# remaining installations after this operation; 0 means a real uninstall.
if [ $1 -eq 0 ] ; then
    /usr/sbin/semodule -n -r %{modulename} &> /dev/null || :
    if /usr/sbin/selinuxenabled ; then
        /usr/sbin/load_policy
    fi
fi

%files
%license LICENSES/GPL-2.0-or-later.txt
%doc packaging/nmap/README.md
%{_datadir}/selinux/packages/%{modulename}.pp
%{_docdir}/%{name}/policy-threat-model.md

%changelog
* Fri Apr 24 2026 Charles Russella <crussella0129@gmail.com> - 0.1.0-1
- Initial release: tricorne_t SELinux integration for nmap.
- Policy module not yet validated against real-tool AVC denials.
