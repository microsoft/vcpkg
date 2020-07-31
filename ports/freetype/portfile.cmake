set(FT_VERSION 2.10.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://download-mirror.savannah.gnu.org/releases/freetype/freetype-${FT_VERSION}.tar.xz" "https://downloads.sourceforge.net/project/freetype/freetype2/${FT_VERSION}/freetype-${FT_VERSION}.tar.xz"
    FILENAME "freetype-${FT_VERSION}.tar.xz"
    SHA512 cf45089bd8893d7de2cdcb59d91bbb300e13dd0f0a9ef80ed697464ba7aeaf46a5a81b82b59638e6b21691754d8f300f23e1f0d11683604541d77f0f581affaa
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${FT_VERSION}
    PATCHES
        0001-Fix-install-command.patch
        0002-Add-CONFIG_INSTALL_PATH-option.patch
        0003-Fix-UWP.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2       FT_WITH_BZIP2
        png         FT_WITH_PNG
    INVERTED_FEATURES
        bzip2       CMAKE_DISABLE_FIND_PACKAGE_BZip2
        png         CMAKE_DISABLE_FIND_PACKAGE_PNG
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCONFIG_INSTALL_PATH=share/freetype
        -DFT_WITH_ZLIB=ON # Force system zlib.
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_HarfBuzz=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig_targets()

file(READ ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freetype2.pc PKGCONFIG_MODULE)
string(REPLACE "-lfreetype" "-lfreetype -lbz2 -lpng16 -lz" PKGCONFIG_MODULE "${PKGCONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freetype2.pc "${PKGCONFIG_MODULE}")
file(READ ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freetype2.pc PKGCONFIG_MODULE)
string(REPLACE "-lfreetyped" "-lfreetyped -lbz2d -lpng16d -lzd" PKGCONFIG_MODULE "${PKGCONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freetype2.pc "${PKGCONFIG_MODULE}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/docs/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if("bzip2" IN_LIST FEATURES)
        set(USE_BZIP2 ON)
    endif()

    if("png" IN_LIST FEATURES)
        set(USE_PNG ON)
    endif()

    configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/freetype/vcpkg-cmake-wrapper.cmake @ONLY)
endif()
