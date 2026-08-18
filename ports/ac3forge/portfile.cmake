# vcpkg port for ac3forge - installs the library only (ac3::forge, plus matroska::matroska,
# mp4::mp4 and mpegts::mpegts behind their own default-on features). Never the CLI, GUI, tests,
# examples or fuzz harnesses - the root CMakeLists.txt's
# AC3FORGE_BUILD_CLI/GUI/TESTS/EXAMPLES/FUZZERS options make that a plain OFF each, no
# vcpkg-specific patching needed. ac3adm::ac3adm (the ADM/BW64 reader) is deliberately NOT a
# feature here - it isn't part of the find_package(ac3forge) package at all (needs Boost,
# consumed only via in-tree add_subdirectory - see docs/library/index.md), so there is nothing
# for a vcpkg feature to install.
#
# Staged here (packaging/vcpkg-port/ac3forge/) for local --overlay-ports
# validation before being copied into a microsoft/vcpkg fork as
# ports/ac3forge/portfile.cmake - see docs/releasing.md.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iainchesworthlabs/ac3forge
    REF "v${VERSION}"
    # Computed directly from https://github.com/iainchesworthlabs/ac3forge/archive/refs/tags/v0.8.0-beta.1.tar.gz
    # (sha512sum) rather than assumed. If `vcpkg install` reports a mismatch
    # on the first real run, GitHub's archive generation differs from this -
    # trust vcpkg's reported hash over this one and update it here.
    SHA512 9e822cb43c7db45527757ebc619a63a125626b527f641d4f49dbbff1f851d452e3c686bc7731b3ec282a7d63307ad1aa61eeb6c6cb79fd00c44fc0112c04aa51
    HEAD_REF main
)

# One vcpkg feature <-> one AC3FORGE_BUILD_<NAME> CMake option. This is the
# pattern a future optional component extends - see cmake/InstallLibrary.cmake's
# header comment in the main repo.
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        matroska AC3FORGE_BUILD_MATROSKA
        mp4      AC3FORGE_BUILD_MP4
        mpegts   AC3FORGE_BUILD_MPEGTS
)

# DERIVED_VERSION_OVERRIDE: cmake/GitVersionDerivation.cmake normally derives
# the project version via `git describe`, which finds nothing in a tarball
# checkout (no .git directory) and silently falls back to "0.0.0-dev". The
# tag vcpkg_from_github() already resolved above is the real version, so
# threading it through here (release.yml's workflow_dispatch path uses the
# same override, for the same reason) keeps the installed package's version
# metadata correct without needing git at all.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DAC3FORGE_BUILD_CLI=OFF
        -DAC3FORGE_BUILD_GUI=OFF
        -DAC3FORGE_BUILD_TESTS=OFF
        -DAC3FORGE_BUILD_EXAMPLES=OFF
        -DAC3FORGE_BUILD_FUZZERS=OFF
        -DAC3FORGE_FETCH_CATCH2=OFF
        -DAC3FORGE_INSTALL_BOTH_LINKAGES=OFF
        "-DDERIVED_VERSION_OVERRIDE=v${VERSION}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME ac3forge CONFIG_PATH lib/cmake/ac3forge)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
