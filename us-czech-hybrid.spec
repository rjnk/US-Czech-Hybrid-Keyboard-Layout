Name:           us-czech-hybrid
Version:        1.0
Release:        1%{?dist}
Summary:        US QWERTY keyboard layout with Czech diacritics
License:        MIT
BuildArch:      noarch
Source0:        us_czech_hybrid
Source1:        evdev.xml
Source2:        LICENSE
Source3:        README.md
Requires:       libxkbcommon >= 1.13
Requires:       xkeyboard-config >= 2.45

%global layoutdir %{_datadir}/xkeyboard-config.d/%{name}

%description
US QWERTY with Czech diacritics on the number row, US Shift symbols,
dead keys for composing accents, and digits on either Alt key.
For Wayland desktops using libxkbcommon and libxkbregistry.

%prep
%setup -q -c -T
cp -p %{SOURCE2} LICENSE
cp -p %{SOURCE3} README.md

%build

%install
install -Dpm 0644 %{SOURCE0} %{buildroot}%{layoutdir}/symbols/us_czech_hybrid
install -Dpm 0644 %{SOURCE1} %{buildroot}%{layoutdir}/rules/evdev.xml

%files
%license LICENSE
%doc README.md
%{layoutdir}/
