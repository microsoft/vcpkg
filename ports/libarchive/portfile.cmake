# libarchive uses winapi functions not available in WindowsStore
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are not supported.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libarchive/libarchive
    REF 614110e76d9dbb9ed3e159a71cbd75fa3b23efe3
    SHA512 8feac2c0e22e5b7c05f3be97c774ad82d39bdea4b3fa3a2b297b85f8a5a9f548c528ef63f5495afd42fb75759e03a4108f3831b27103f899f8fe4ef7e8e2d1cf
    HEAD_REF master
    PATCHES
        fix-buildsystem.patch
        fix-dependencies.patch
        fix-lz4.patch
        fix-zstd.patch
        fix-cpu-set.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    bzip2    ENABLE_BZip2
    libxml2  ENABLE_LIBXML2
    lz4      ENABLE_LZ4
    lzma     ENABLE_LZMA
    lzo      ENABLE_LZO
    openssl  ENABLE_OPENSSL
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_PCREPOSIX=OFF
        -DENABLE_NETTLE=OFF
        -DENABLE_EXPAT=OFF
        -DENABLE_LibGCC=OFF
        -DENABLE_CNG=OFF
        -DENABLE_TAR=OFF
        -DENABLE_CPIO=OFF
        -DENABLE_CAT=OFF
        -DENABLE_XATTR=OFF
        -DENABLE_ACL=OFF
        -DENABLE_TEST=OFF
        -DENABLE_ICONV=OFF
        -DPOSIX_REGEX_LIB=NONE
        -DENABLE_WERROR=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
foreach(HEADER ${CURRENT_PACKAGES_DIR}/include/archive.h ${CURRENT_PACKAGES_DIR}/include/archive_entry.h)
    file(READ ${HEADER} CONTENTS)
    string(REPLACE "(!defined LIBARCHIVE_STATIC)" "0" CONTENTS "${CONTENTS}")
    file(WRITE ${HEADER} "${CONTENTS}")
endforeach()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libarchive)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
