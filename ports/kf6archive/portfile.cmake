vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF "v${VERSION}"
    SHA512 d3516e17a98cfa40ce3f863dc2b209361435de5c76a42423ac2518602ca71b54ac3294ebaa93d38c904b3a0b968fab52e754c32c9c70c938d310e3d5acb50229
    HEAD_REF master
    PATCHES
        zstd.diff
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2           WITH_BZIP2
        bzip2           VCPKG_LOCK_FIND_PACKAGE_BZip2
        lzma            WITH_LIBLZMA
        lzma            VCPKG_LOCK_FIND_PACKAGE_LibLZMA
        zstd            WITH_LIBZSTD
        zstd            VCPKG_LOCK_FIND_PACKAGE_LibZstd
    INVERTED_FEATURES
        translations    KF_SKIP_PO_PROCESSING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=1
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF6Archive)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
