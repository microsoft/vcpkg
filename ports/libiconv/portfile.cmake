set(LIBICONV_VERSION 1.15)

# this port might require a staging area to be proper installed. In fact, it is tightly coupled to gettext and the build order should be
# libiconv -> gettext -> libiconv

if (VCPKG_TARGET_IS_WINDOWS)
    set(ADDITIONAL_PATCHES "0001-Add-export-definitions.patch;0002-Config-for-MSVC.patch")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz"
    FILENAME "libiconv-${LIBICONV_VERSION}.tar.gz"
    SHA512 1233fe3ca09341b53354fd4bfe342a7589181145a1232c9919583a8c9979636855839049f3406f253a9d9829908816bb71fd6d34dd544ba290d6f04251376b1a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIBICONV_VERSION}
    PATCHES
        ${ADDITIONAL_PATCHES}
)

if (VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
    )

    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-iconv TARGET_PATH share/unofficial-iconv)
    vcpkg_copy_pdbs()
    vcpkg_test_cmake(PACKAGE_NAME unofficial-iconv)
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
    )
    vcpkg_build_make(
        ENABLE_INSTALL
    )

    vcpkg_fixup_pkgconfig_targets()

    file(GLOB_RECURSE TOOLS_EXES ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    file(INSTALL ${TOOLS_EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
