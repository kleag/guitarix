The guitarix-kleag packages are built by GitHub Actions in your fork when you push a tag. You build nothing locally: you merge the fix into the packaging branch, then tag and push.

1. Merge the fix into the packaging branch, in the ~/Developpements/guitarix-pkg checkout (branch kleag-pkg):

cd ~/Developpements/guitarix-pkg
git fetch kleag
git merge kleag/jsonrpc-utf8-names        # the non-ASCII preset fix
git push kleag kleag-pkg

2. Tag and push the tag. This starts the "Packages" workflow (.github/workflows/packages.yml). Earlier tags were pkg-20261029, pkg-20261029b and pkg-20261029c, so today's would be:

git tag pkg-20261030
git push kleag pkg-20261030

3. What CI does next:
- Builds the .debs with .github/scripts/build-deb.sh for two targets:
  - Ubuntu resolute (26.04) on amd64;
  - Debian bookworm on arm64, which is the one for the Pi.

  The version looks like 0.47.0+kleag<run>.g<sha>~<suite>.
- Rebuilds the signed apt repository (secret APT_SIGNING_KEY) and force-pushes it to gh-pages. That repository only ever holds the latest build.
- Attaches the debs to a pre-release named after the tag.

You can also rerun the workflow without a tag (workflow_dispatch, e.g. gh workflow run Packages -R kleag/guitarix --ref kleag-pkg). That updates the apt repository but creates no release.

4. On the Pi: sudo apt update && sudo apt upgrade gets the new guitarix-kleag. Then restart the engine, which is needed in any case after this freeze.

To confirm the fix is in the installed engine, select "Les Écorchés" with guitariqx connected. It should load with no "blocked the engine" message in the status bar.

