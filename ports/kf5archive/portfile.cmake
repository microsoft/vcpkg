vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF "v${VERSION}"
    SHA512 2423f6f99a610cf376f14f95fe8af9f9b66a7ce95d082773442cb27046a0bde9d0b80cb5e9798bb44147e27b6749b834034321b13f109482daef60634ee97a69
    HEAD_REF master
    PATCHES
        zstd.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2   VCPKG_LOCK_FIND_PACKAGE_BZip2
        lzma    VCPKG_LOCK_FIND_PACKAGE_LibLZMA
        zstd    VCPKG_LOCK_FIND_PACKAGE_LibZstd
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Archive)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
