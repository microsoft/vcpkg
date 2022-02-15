vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libarchive/libarchive
    REF 1b2c437b99b361c7692538fa373e99955e9b93ae      #v3.5.2
    SHA512 df527dd333b01ed85f07831ba0bd4b1d0b5384fe12cfa53474ad39c04509105a3c8574a2d21a430e3584a931c8f6ae923bca95df83945f0c593c1ffaed3f62da
    HEAD_REF master
    PATCHES
        disable-warnings.patch
        fix-buildsystem.patch
        fix-cpu-set.patch
        fix-dependencies.patch
        pkgconfig-modules.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2   ENABLE_BZip2
        libxml2 ENABLE_LIBXML2
        lz4     ENABLE_LZ4
        lzma    ENABLE_LZMA
        lzo     ENABLE_LZO
        openssl ENABLE_OPENSSL
        zstd    ENABLE_ZSTD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_ZLIB=ON
        -DENABLE_PCREPOSIX=OFF
        -DPOSIX_REGEX_LIB=NONE
        -DENABLE_NETTLE=OFF
        -DENABLE_EXPAT=OFF
        -DENABLE_LibGCC=OFF
        -DENABLE_CNG=OFF
        -DENABLE_TAR=OFF
        -DENABLE_CPIO=OFF
        -DENABLE_CAT=OFF
        -DENABLE_XATTR=OFF
        -DENABLE_ACL=OFF
        -DENABLE_ICONV=OFF
        -DENABLE_LIBB2=OFF
        -DENABLE_TEST=OFF
        -DENABLE_WERROR=OFF
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

foreach(header "${CURRENT_PACKAGES_DIR}/include/archive.h" "${CURRENT_PACKAGES_DIR}/include/archive_entry.h")
    vcpkg_replace_string("${header}" "(!defined LIBARCHIVE_STATIC)" "0")
endforeach()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
