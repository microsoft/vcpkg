vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF "v${VERSION}"
    SHA512 a4f097c51648b3f9469b6ea9e5b922fefce7f0734a8f2be0bbf0d602bc98345fce2914ede626bf93d38e79a9e5d751284663b122297f82ec079fb1035a5b7378
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
