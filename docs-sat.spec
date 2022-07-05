#
# MIT License
#
# (C) Copyright 2022 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# RPM specfile for docs-sat RPM

Name: docs-sat
License: MIT License
Summary: Documentation for System Admin Toolkit (SAT)
BuildArchitectures: noarch
Version: %(./version.sh)
Release: %(echo ${BUILD_METADATA})
Source: %{name}-%{version}.tar.bz2
Vendor: Hewlett Packard Enterprise Company

%description
This package contains documentation about the System Admin Toolkit (SAT)
in Markdown format starting at /usr/share/doc/sat/README.md.

%prep
%setup -q

%build

%install
install -m 755 -d %{buildroot}/usr/share/doc/sat/
# The docs/ directory will be installed in /usr/share/doc/sat/
cp -pvr docs/* %{buildroot}/usr/share/doc/sat/
# Except that README.md will be rpm/README.md concatenated with docs/README.md
cat rpm/README.md > %{buildroot}/usr/share/doc/sat/README.md
# Add an empty line between the files.
echo >> %{buildroot}/usr/share/doc/sat/README.md
cat docs/README.md >> %{buildroot}/usr/share/doc/sat/README.md

%clean

%files
/usr/share/doc/sat/

%docdir /usr/share/doc/sat/
%license LICENSE
