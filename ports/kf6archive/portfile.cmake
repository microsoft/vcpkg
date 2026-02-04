vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF "v${VERSION}"
    SHA512 d6ab327b5c42c3221348d797e575984d50790f46db6f7e92dd442f7792e88804f88054fb4bcaf6b12470f992f0a18065a2aafa67eb4d4784d5caf0082c4d4b0e
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
