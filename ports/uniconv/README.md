UniConv vcpkg port
===================

This directory contains a local vcpkg port for `uniconv` to make it easy to
test and submit a port to the official vcpkg repository.

Files:

- `vcpkg.json` - port manifest
- `portfile.cmake` - build/install instructions for vcpkg

Notes before submission:

- License: The project is MIT licensed, but includes code from GNU libiconv
  (LGPL). When submitting to vcpkg, you must ensure licensing metadata is
  correctly represented and that users are aware of the bundled LGPL parts.

- The port currently uses the repository root as the source. For an upstream
  submission PR it's recommended to change `vcpkg_from_git` usage to fetch a
  release tarball from the project's GitHub releases.

Local testing with `vcpkg`:

1. Clone vcpkg and bootstrap it (see vcpkg docs).
2. From the vcpkg repo root run:

```bash
# Add the local ports overlay
./vcpkg install --overlay-ports=/path/to/UniConv/contrib/vcpkg/ports uniconv
```

Replace `/path/to/UniConv` with the absolute path to this repository.

Submitting a PR to vcpkg:

1. Prepare a stable release (tag) or use a release tarball URL.
2. Update `portfile.cmake` to download the release tarball using
   `vcpkg_from_github` or `vcpkg_from_git` with an explicit tag/commit.
3. Ensure `vcpkg.json` version string matches the release.
4. Create a PR against `microsoft/vcpkg` following vcpkg port submission
   guidelines: https://github.com/microsoft/vcpkg/blob/master/docs/maintainers/authoring.md
