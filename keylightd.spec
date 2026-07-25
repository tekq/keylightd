Name: keylightd
Version: 1.1.1
Release: 0%{?dist}
Summary: Keyboard backlight daemon for the Framework Laptop

License: 0BSD
URL: https://github.com/tekq/keylightd
Source0: %{name}-%{version}.tar.gz
Source1: %{name}-%{version}-vendor.tar.gz

BuildRequires: cargo
BuildRequires: rust
BuildRequires: systemd-rpm-macros
%{?systemd_requires}

%description
keylightd is a small system daemon for Framework laptops
that listens to keyboard and touchpad input, and turns
on the keyboard backlight while either is being used.

%prep
%autosetup -n %{name}-%{version}
tar -xf %{SOURCE1}
mkdir -p .cargo
cat > .cargo/config.toml <<'EOF'
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"
EOF

%build
cargo build --release --offline

%install
install -Dm0755 target/release/keylightd %{buildroot}%{_bindir}/keylightd
install -Dm0644 etc/keylightd.service %{buildroot}%{_unitdir}/keylightd.service

%post
%systemd_post keylightd.service

%preun
%systemd_preun keylightd.service

%postun
%systemd_postun_with_restart keylightd.service

%files
%license LICENSE
%doc README.md
%{_bindir}/keylightd
%{_unitdir}/keylightd.service

%changelog
* Wed Jul 22 2026 asmx2 <hello@asmx2.dev> - 1.1.0-1
- Initial COPR packaging
