set(VCPKG_LIBRARY_LINKAGE static)  # static-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hasherezade/libpeconv
    REF e90f7423a0232e4ce765ad7118a7212825e11e8f
    SHA512 e18bdebd77d4d1e3c13133586b590821e726314f7bdc097c1cee1a129b9bfda0bcde74f665f0c89d3afdb38bdb4cf0ce1ebbe32efa85df72f251b08e8d12f994
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        unicode PECONV_UNICODE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPECONV_BUILD_TESTING=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
