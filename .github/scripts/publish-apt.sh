#!/bin/sh
# Build a signed apt repository from the .debs in DEBDIR/<suite>/ into SITE.
# Usage: publish-apt.sh DEBDIR SITE PAGES_URL
# The signing key must already be imported into gpg (it is the only key).
set -eu

debdir=$1
site=$(realpath -m "$2")
url=$3

mkdir -p "$site" conf
: > conf/distributions
for dir in "$debdir"/*/; do
    suite=$(basename "$dir")
    cat >> conf/distributions <<CONF
Codename: $suite
Suite: $suite
Components: main
Architectures: amd64 arm64
Origin: kleag
Label: guitarix (kleag)
Description: guitarix packages built from github.com/kleag/guitarix
SignWith: default

CONF
done

for dir in "$debdir"/*/; do
    suite=$(basename "$dir")
    reprepro --confdir "$PWD/conf" --dbdir "$PWD/db" --outdir "$site" includedeb "$suite" "$dir"*.deb
done

gpg --armor --export > "$site/kleag-guitarix.asc"
touch "$site/.nojekyll"
cat > "$site/index.html" <<HTML
<!doctype html>
<html><head><meta charset="utf-8"><title>guitarix apt repository</title></head>
<body>
<h1>guitarix (kleag) apt repository</h1>
<p>Suites: $(ls "$debdir" | tr '\n' ' ')</p>
<pre>
sudo install -d /etc/apt/keyrings
sudo curl -fsSLo /etc/apt/keyrings/kleag-guitarix.asc $url/kleag-guitarix.asc
printf 'Types: deb\nURIs: $url\nSuites: %s\nComponents: main\nSigned-By: /etc/apt/keyrings/kleag-guitarix.asc\n' \\
  "\$(. /etc/os-release; echo \$VERSION_CODENAME)" | sudo tee /etc/apt/sources.list.d/kleag-guitarix.sources
sudo apt update
sudo apt install guitarix-kleag
</pre>
</body></html>
HTML
