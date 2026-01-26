vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF "v${VERSION}"
    SHA512 f87fd53ba029b05d3c233ea8d8a9dbb7b2aba2aec55a38b26cfd0f6e1c49d8c1297c06d634175ccc5bbbce00261a3387a2da3c705011e9cbae538eae2723fef3
    HEAD_REF master
    PATCHES
        zstd.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
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
        ${options}
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=1
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF6Archive)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
