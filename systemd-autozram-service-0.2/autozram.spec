#
# spec file for package systemd-autozram-service
#
# Copyright (c) 2017 Mihail Gershkovich <Mihail.Gershkovich@gmail.com>
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:           systemd-autozram-service
Version:        0.2
Release:        1
License:        GPL-2.0
Summary:        Systemd service for zram swap
Url:            https://www.kernel.org/doc/Documentation/blockdev/zram.txt
Group:          System/Daemons
Source0:        systemd-autozram-service-0.2.tar.bz2
Source1:        autozramon
Source2:        autozramoff
Source3:        autozram.service
Source4:        autozram.conf
BuildRequires:  systemd
Requires:       systemd
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
Creates a compressed in-memory swap device based on zram technology.
This version creates one drive with multiple compression streams
And fair limitation on memory consumption. (Disksize <> max memory consumed).
Default compression: lzo (est. compression ratio 2:1)
Alternative or complimentary to swap on persistent devices like hdd or ssd.

%prep
%setup -q -n systemd-autozram-service-%{version}

%build
# No building required, just a placehoder.

%install
mkdir -p %{buildroot}%{_sbindir}
install -m 0755 %{S:1} %{S:2} %{buildroot}%{_sbindir}/
mkdir -p %{buildroot}%{_unitdir}
install -m 0644 %{S:3} %{buildroot}%{_unitdir}/
mkdir -p %{buildroot}/etc/
install -m 0644 %{S:4} %{buildroot}/etc/

%pre
%service_add_pre autozram.service

%post
%service_add_post autozram.service

%preun
%service_del_preun autozram.service

%postun
%service_del_postun autozram.service

%files
%defattr(-,root,root,-)
#%doc README.md
%{_sbindir}/autozram*
%{_unitdir}/autozram.service
%config(noreplace) /etc/autozram.conf

%changelog
