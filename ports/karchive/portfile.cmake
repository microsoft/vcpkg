vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF "v${VERSION}"
    SHA512 3cc0e52c4d0aa603792f8ecb33ce0ed944986172f5e2b871f0647818c2f9d8b9789907f8548576476b293d835b9823eef76a6d2f440afc00ba94c2948e4c3492
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
        openssl         WITH_OPENSSL
        openssl         VCPKG_LOCK_FIND_PACKAGE_OpenSSL
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
        -DECM_PKGCONFIG_INSTALL_DIR:PATH="${CURRENT_PACKAGES_DIR}/discard_pkgconfig"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6archive
    CONFIG_PATH lib/cmake/KF6Archive
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/discard_pkgconfig"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
