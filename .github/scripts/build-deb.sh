#!/bin/sh
# Build the guitarix .deb for one suite inside a matching container.
# Usage: build-deb.sh SUITE BUILD_NUMBER OUTDIR
# Run from the repository root, as root (the CI container is root).
set -eu

suite=$1
build=$2
outdir=$3

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends ca-certificates git build-essential dpkg-dev
git config --global --add safe.directory "*"
apt-get build-dep -y ./trunk

upstream=$(sed -n "s/^VERSION='\(.*\)'/\1/p" trunk/wscript)
sha=$(git rev-parse --short=8 HEAD 2>/dev/null || echo unknown)
version="${upstream}+kleag${build}.g${sha}~${suite}"
desc=$(git describe --tags --always 2>/dev/null || echo "$sha")

rm -f trunk/debian/changelog
cat > trunk/debian/changelog <<CHANGELOG
guitarix-kleag (${version}) ${suite}; urgency=medium

  * Automated build of ${desc}.

 -- Gaël de Chalendar <kleagg@gmail.com>  $(date -R)
CHANGELOG

cd trunk
DEB_BUILD_OPTIONS="noddebs nocheck parallel=$(nproc)" dpkg-buildpackage -b -us -uc
cd ..
mkdir -p "$outdir"
mv guitarix-kleag_*.deb "$outdir"/
ls -l "$outdir"
