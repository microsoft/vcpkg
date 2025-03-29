vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libarchive/libarchive
    REF "v${VERSION}"
    SHA512 5ce1fb0b0108a1f5a1547fbecc261e0438b449eee7253eec0b66452462c052b09c8e6cccd0ed9e7fd0c55e5862b334519b17da4f72b1e0196e73bc90ad97c983
    HEAD_REF master
    PATCHES
        disable-warnings.patch
        fix-buildsystem.patch
        fix-cpu-set.patch
        fix-deps.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2   ENABLE_BZip2
        bzip2   CMAKE_REQUIRE_FIND_PACKAGE_BZip2
        libxml2 ENABLE_LIBXML2
        libxml2 CMAKE_REQUIRE_FIND_PACKAGE_LibXml2
        lz4     ENABLE_LZ4
        lz4     CMAKE_REQUIRE_FIND_PACKAGE_lz4
        lzma    ENABLE_LZMA
        lzma    CMAKE_REQUIRE_FIND_PACKAGE_LibLZMA
        lzo     ENABLE_LZO
        zstd    ENABLE_ZSTD
)
# Default crypto backend is OpenSSL, but it is ignored for DARWIN
set(WRAPPER_ENABLE_OPENSSL OFF)
if(NOT "crypto" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS
        -DLIBMD_FOUND=FALSE
        -DENABLE_OPENSSL=OFF
    )
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND FEATURE_OPTIONS
        -DENABLE_MBEDTLS=ON
        -DENABLE_OPENSSL=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_MbedTLS=ON
    )
else()
    set(WRAPPER_ENABLE_OPENSSL ON)
    list(APPEND FEATURE_OPTIONS
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_ZLIB=ON
        -DENABLE_PCREPOSIX=OFF
        -DPOSIX_REGEX_LIB=NONE
        -DENABLE_MBEDTLS=OFF
        -DENABLE_NETTLE=OFF
        -DENABLE_EXPAT=OFF
        -DENABLE_LibGCC=OFF
        -DENABLE_CNG=OFF
        -DENABLE_UNZIP=OFF
        -DENABLE_TAR=OFF
        -DENABLE_CPIO=OFF
        -DENABLE_CAT=OFF
        -DENABLE_XATTR=OFF
        -DENABLE_ACL=OFF
        -DENABLE_ICONV=OFF
        -DENABLE_LIBB2=OFF
        -DENABLE_TEST=OFF
        -DENABLE_WERROR=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_BZip2
        CMAKE_REQUIRE_FIND_PACKAGE_LibLZMA
        CMAKE_REQUIRE_FIND_PACKAGE_LibXml2
        CMAKE_REQUIRE_FIND_PACKAGE_lz4
        ENABLE_LibGCC
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(REMOVE_RECURSE
      "${CURRENT_PACKAGES_DIR}/debug/include"
      "${CURRENT_PACKAGES_DIR}/debug/share"
      "${CURRENT_PACKAGES_DIR}/share/man"
)

foreach(header "include/archive.h" "include/archive_entry.h")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/${header}" "(!defined LIBARCHIVE_STATIC)" "0")
endforeach()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
