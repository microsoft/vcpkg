if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/unofficial-iconv)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-iconv-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-iconv)
    return()
endif()

set(LIBICONV_VERSION 1.16)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz"
    FILENAME "libiconv-${LIBICONV_VERSION}.tar.gz"
    SHA512 365dac0b34b4255a0066e8033a8b3db4bdb94b9b57a9dca17ebf2d779139fe935caf51a465d17fd8ae229ec4b926f3f7025264f37243432075e5583925bb77b7
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIBICONV_VERSION}
    PATCHES
        0002-Config-for-MSVC.patch
        0003-Add-export.patch
)

#Since libiconv uses automake, make and configure, we use a custom CMake file
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DINSTALLDIR=\"\" -DLIBDIR=\"\"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-iconv TARGET_PATH share/unofficial-iconv)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/Iconv)

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME unofficial-iconv)

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
