vcpkg_download_distfile(PATCH_BLAKE3_PR_482
    URLS https://github.com/BLAKE3-team/BLAKE3/commit/cd6e3e4dd9a9518be45ef742606462ddfb0f3cfd.patch
    SHA512 a2e6179f577d4b4b3aa83d2f44e2d2a346808fc130f262047e749ee50126970fae1b1d5edf910dae664b65871fadf05cdc2b80c0a8e520807340cf404756ffc5
    FILENAME cd6e3e4dd9a9518be45ef742606462ddfb0f3cfd.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE3-team/BLAKE3
    REF "${VERSION}"
    SHA512 5832d15373a0ec224e3c8dc86e1540e9246efbdf8db88fc2cce8924552f632532d9b74eeb15e1d31e3f13676656b5230d009151b4c57eb9d84224a9e385ba839
    HEAD_REF main
    PATCHES
        fix-windows-arm-build-error.patch
        "${PATCH_BLAKE3_PR_482}"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS BLAKE3_FEATURE_OPTIONS
    FEATURES
        tbb BLAKE3_USE_TBB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/c"
    OPTIONS
        ${BLAKE3_FEATURE_OPTIONS}
        -DBLAKE3_FETCH_TBB=OFF
        -DBLAKE3_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_A2" "${SOURCE_PATH}/LICENSE_A2LLVM" "${SOURCE_PATH}/LICENSE_CC0")
