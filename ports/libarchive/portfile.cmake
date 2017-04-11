# libarchive uses winapi functions not available in WindowsStore
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are not supported.")
endif()

include(vcpkg_common_functions)
set(ARCHIVE_VERSION 3.3.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libarchive-${ARCHIVE_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libarchive/libarchive/archive/v${ARCHIVE_VERSION}.zip"
    FILENAME "libarchive-${ARCHIVE_VERSION}.zip"
    SHA512 a54fe3c5c24c83df244f3f2346212a6aa8d8945cf4ddc407e54c891ebbf8c98b93492e5652c9813a6d5dc654a32479e08a40bb0d2af7400a29ac027028e986f5)

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-buildsystem.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_LZO=OFF
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
        -DPOSIX_REGEX_LIB=NONE)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
foreach(HEADER ${CURRENT_PACKAGES_DIR}/include/archive.h ${CURRENT_PACKAGES_DIR}/include/archive_entry.h)
    file(READ ${HEADER} CONTENTS)
    string(REPLACE "(!defined LIBARCHIVE_STATIC)" "0" CONTENTS "${CONTENTS}")
    file(WRITE ${HEADER} "${CONTENTS}")
endforeach()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libarchive)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libarchive/COPYING ${CURRENT_PACKAGES_DIR}/share/libarchive/copyright)
