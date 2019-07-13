#
# spec file for package systemd-autozram-service
#
# Copyright (c) 2017-2019 Mihail Gershkovich <Mihail.Gershkovich@gmail.com>
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

Name:           zramservice
Version:        1.2
Release:        1
License:        GPL-2.0
Summary:        Systemd service for zram drives
Url:            https://www.kernel.org/doc/Documentation/blockdev/zram.txt
Group:          System/Daemons
Source0:        zramservice.tar.bz2
Source1:        zramon
Source2:        zramoff
Source3:        zram.service
Source4:        zramservice.conf
#BuildRequires:  systemd
Requires:       systemd
BuildRoot:      %{_tmppath}/%{name}-build
BuildArch:      noarch

%description
Creates compressed in-memory drives with zram as systemd service.
Can create swap and normal drives. Includes default values and stable options.
Default compression: lzo (est. compression ratio 2:1)

%prep
%setup -q -n zramservice

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
%service_add_pre zram.service

%post
%service_add_post zram.service

%preun
%service_del_preun zram.service

%postun
%service_del_postun zram.service

%files
%defattr(-,root,root,-)
#%doc README.md
%{_sbindir}/zramo*
%{_unitdir}/zram.service
%config(noreplace) /etc/zramservice.conf

%changelog
