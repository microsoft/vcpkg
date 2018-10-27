if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/unofficial-iconv)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-iconv-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-iconv)
    return()
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libiconv-1.15)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libiconv/libiconv-1.15.tar.gz"
    FILENAME "libiconv-1.15.tar.gz"
    SHA512 1233fe3ca09341b53354fd4bfe342a7589181145a1232c9919583a8c9979636855839049f3406f253a9d9829908816bb71fd6d34dd544ba290d6f04251376b1a
)
vcpkg_extract_source_archive(${ARCHIVE})

#Since libiconv uses automake, make and configure, we use a custom CMake file
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-Add-export-definitions.patch
            ${CMAKE_CURRENT_LIST_DIR}/0002-Config-for-MSVC.patch
            ${CMAKE_CURRENT_LIST_DIR}/0003-Fix-uwp.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-iconv TARGET_PATH share/unofficial-iconv)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/libiconv)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libiconv/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/libiconv/copyright)

vcpkg_test_cmake(PACKAGE_NAME unofficial-iconv)