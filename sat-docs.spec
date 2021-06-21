Summary:       SAT Documentation
Name:          sat-docs
Version:       %(cat .version)
Release:       %(cat .version)
Group:         Software
License:       HPE Software License Agreement
URL:           http://www.hpe.com
Prefix:        %{_prefix}
BuildRoot:     %{buildroot}
Source0:       %{name}-%{version}.tar.bz2

%description
SAT documentation, provides PDFs and HTML

%prep
%setup -q

%build

%install
mkdir -p ${RPM_BUILD_ROOT}/usr/share/doc/%{name}/
mkdir -p ${RPM_BUILD_ROOT}/var/www/product_name/%{name}

cp -a pdf/* ${RPM_BUILD_ROOT}/usr/share/doc/%{name}/.
cp -a html/* ${RPM_BUILD_ROOT}/usr/share/doc/%{name}/.

chmod -R 555 ${RPM_BUILD_ROOT}/usr/share/doc/%{name}
chmod -R 555 ${RPM_BUILD_ROOT}/var/www/product_name/%{name}

%files
%docdir /usr/share/doc/%{name}
%docdir /var/www/product_name/%{name}
/var/www/product_name/%{name}/*
/usr/share/doc/%{name}/*

%changelog
* Mon Mar 29 2021 HPE Cray <hpecray@hpe.com> - %{version}
- Initial docs version
