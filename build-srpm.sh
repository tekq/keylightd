#!/usr/bin/env bash
set -euo pipefail

NAME=keylightd
VERSION=$(grep -m1 '^version' Cargo.toml | cut -d '"' -f2)

command -v rpmdev-setuptree >/dev/null || { echo "Install rpmdevtools first"; exit 1; }
command -v cargo >/dev/null || { echo "Install cargo first"; exit 1; }

rpmdev-setuptree

echo "Archiving source tree at $(git rev-parse --short HEAD)"
git archive --format=tar --prefix="${NAME}-${VERSION}/" HEAD \
  | gzip > "${HOME}/rpmbuild/SOURCES/${NAME}-${VERSION}.tar.gz"

echo "Vendoring crate dependencies"
rm -rf vendor
cargo vendor vendor >/dev/null
tar --sort=name --owner=0 --group=0 --numeric-owner \
    -czf "${HOME}/rpmbuild/SOURCES/${NAME}-${VERSION}-vendor.tar.gz" vendor
rm -rf vendor

cp keylightd.spec "${HOME}/rpmbuild/SPECS/"

echo "Building SRPM"
rpmbuild -bs "${HOME}/rpmbuild/SPECS/${NAME}.spec"

echo
echo "Done. SRPM is in ${HOME}/rpmbuild/SRPMS/"
echo "To test locally: mock -r fedora-44-x86_64 ${HOME}/rpmbuild/SRPMS/${NAME}-${VERSION}-1*.src.rpm"
echo "To submit to COPR: copr-cli build keylightd ${HOME}/rpmbuild/SRPMS/${NAME}-${VERSION}-1*.src.rpm"
