# Open3D vcpkg Port Design

**Date:** 2026-08-04

## Goal

Add an `open3d` vcpkg port based on the Open3D upstream `main` commit that
contains PR #7386, with CPU support by default and CUDA support through an
optional `cuda` feature. GUI support is out of scope until Filament is
available as a vcpkg port.

## Source and versioning

- Repository: `isl-org/Open3D`
- Revision: `df18cd291b996035267672d4fbf847095d057f4a`
- Upstream version scheme: `version-semver: 0.19.0`, matching Open3D's
  upstream `vcpkg.json`
- Port version: `1`, because the packaged revision is the post-`v0.19.0`
  upstream `main` revision rather than the released tag
- No vcpkg patch for PR #7386; the changes are already present in the pinned
  upstream revision

## Port behavior

The base port builds the C++ library only:

- `BUILD_GUI=OFF` and `BUILD_FILAMENT_FROM_SOURCE=OFF`
- `BUILD_PYTHON_MODULE=OFF`
- `BUILD_EXAMPLES=OFF`, `BUILD_UNIT_TESTS=OFF`, and `BUILD_BENCHMARKS=OFF`
- sensor, ML-ops, WebRTC, Jupyter, ISPC, IPP, and MiniZIP options disabled
- `OPEN3D_USE_VCPKG=ON` so Open3D uses the vcpkg-compatible system dependency
  discovery added by PR #7386
- `BUILD_SHARED_LIBS` follows `VCPKG_LIBRARY_LINKAGE`
- `STATIC_WINDOWS_RUNTIME` follows `VCPKG_CRT_LINKAGE`

The `cuda` feature:

- depends on the vcpkg `cuda` port, which verifies that a CUDA Toolkit is
  already installed; it does not install the toolkit
- maps to `BUILD_CUDA_MODULE=ON` with `vcpkg_check_features`
- remains opt-in so CPU-only consumers do not require a CUDA installation

The base dependency list follows Open3D's upstream vcpkg manifest and adds
the direct `opengl` dependency required by the upstream CMake configuration.
GUI-only Filament and ImGui dependencies are omitted because GUI is disabled.

## Files

- `ports/open3d/portfile.cmake`: source download, feature-to-CMake mapping,
  CMake configure/install, config fixup, and copyright installation
- `ports/open3d/vcpkg.json`: package metadata, direct dependencies, and the
  `cuda` feature
- `versions/o-/open3d.json` and `versions/baseline.json`: generated with
  `vcpkg x-add-version open3d`

No tests, docs, examples, or Filament port are added in this change.

## Verification

1. Format the manifest with `vcpkg format-manifest ports/open3d/vcpkg.json`.
2. Run `vcpkg x-add-version open3d` and verify only the new port's version
   metadata changes.
3. Install the base port on the host triplet.
4. Install `open3d[cuda]` when a supported CUDA Toolkit is available.
5. Build a small CMake consumer using `find_package(Open3D CONFIG REQUIRED)`
   and link `Open3D::Open3D` for both configurations where available.
6. Run vcpkg port checks and inspect the installed tree for debug headers,
   stale GUI resources, and missing copyright/config files.
