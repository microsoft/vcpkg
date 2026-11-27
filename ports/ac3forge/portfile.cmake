# vcpkg port for ac3forge - installs the library only (ac3::forge, plus matroska::matroska,
# mp4::mp4 and mpegts::mpegts as opt-in features), never the CLI, GUI, tests, examples or fuzz
# harnesses - upstream's own AC3FORGE_BUILD_CLI/GUI/TESTS/EXAMPLES/FUZZERS options make that a
# plain OFF each, no patching needed. ac3adm::ac3adm (the ADM/BW64 reader) has no feature here:
# it needs Boost and is only ever consumed in-tree via add_subdirectory, never through
# find_package(ac3forge).

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iainchesworthlabs/ac3forge
    REF "v${VERSION}"
    SHA512 05e021523fc77c62ccae44279e6bb46bf9fd5685c0400e0fee4257f10465c21b0c75d419281599b1b49b8e862720b7375011db7a3edcee6e1bb9aadab7189649
    HEAD_REF main
)

# One vcpkg feature <-> one AC3FORGE_BUILD_<NAME> CMake option.
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        matroska AC3FORGE_BUILD_MATROSKA
        mp4      AC3FORGE_BUILD_MP4
        mpegts   AC3FORGE_BUILD_MPEGTS
)

# DERIVED_VERSION_OVERRIDE: upstream derives its version via `git describe`, which finds nothing
# in a tarball checkout and falls back to "0.0.0-dev" - thread the real tag through instead.
#
# AC3FORGE_BUILD_ADM/AC3FORGE_ENABLE_TRACY are already OFF by upstream's own default; pinned
# explicitly so a future default change upstream can't silently pull an undeclared dependency
# into this port. AC3FORGE_WITH_ALSA/AC3FORGE_WITH_PIPEWIRE default to AUTO upstream and would
# otherwise probe the build machine's ambient ALSA/PipeWire installs even though this
# library-only build never builds, links or installs ac3::audio at all.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DAC3FORGE_BUILD_CLI=OFF
        -DAC3FORGE_BUILD_GUI=OFF
        -DAC3FORGE_BUILD_TESTS=OFF
        -DAC3FORGE_BUILD_EXAMPLES=OFF
        -DAC3FORGE_BUILD_FUZZERS=OFF
        # ac3::forge_c (roadmap F1) was never part of this port's scope, and
        # its capiTargets export set currently requires forge_static even
        # when AC3FORGE_INSTALL_BOTH_LINKAGES=OFF leaves that target
        # unexported - a real bug independent of vcpkg, tracked separately.
        -DAC3FORGE_BUILD_CAPI=OFF
        -DAC3FORGE_FETCH_CATCH2=OFF
        -DAC3FORGE_INSTALL_BOTH_LINKAGES=OFF
        -DAC3FORGE_BUILD_ADM=OFF
        -DAC3FORGE_ENABLE_TRACY=OFF
        -DAC3FORGE_WITH_ALSA=OFF
        -DAC3FORGE_WITH_PIPEWIRE=OFF
        "-DDERIVED_VERSION_OVERRIDE=v${VERSION}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME ac3forge CONFIG_PATH lib/cmake/ac3forge)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
