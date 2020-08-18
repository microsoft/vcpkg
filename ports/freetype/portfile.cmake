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
        0003-Fix-UWP.patch
        pkgconfig.patch
        brotli-static.patch
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
        -DFT_WITH_ZLIB=ON # Force system zlib.
        -DFT_WITH_BROTLI=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_HarfBuzz=ON
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/freetype)

# Rename for easy usage (VS integration; CMake and autotools will not care)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/freetype2/freetype ${CURRENT_PACKAGES_DIR}/include/freetype)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/freetype2/ft2build.h ${CURRENT_PACKAGES_DIR}/include/ft2build.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/freetype2)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Fix the include dir [freetype2 -> freetype]
file(READ ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-config.cmake CONFIG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}/include/freetype2" "\${_IMPORT_PREFIX}/include" CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlidec-static.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlidec-static.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlidec-static.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlidec.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlidec.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlidec.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlidec.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlidec.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlidec.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-config.cmake "${CONFIG_MODULE}")

find_library(FREETYPE_DEBUG NAMES freetyped PATHS "${CURRENT_PACKAGES_DIR}/debug/lib/" NO_DEFAULT_PATH)
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freetype2.pc")
    file(READ "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freetype2.pc" _contents)
    if(FREETYPE_DEBUG)
        string(REPLACE "-lfreetype" "-lfreetyped" _contents "${_contents}")
    endif()
    string(REPLACE "-I\${includedir}/freetype2" "-I\${includedir}" _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freetype2.pc" "${_contents}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freetype2.pc")
    file(READ "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freetype2.pc" _contents)
    string(REPLACE "-I\${includedir}/freetype2" "-I\${includedir}" _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freetype2.pc" "${_contents}")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY
    ${SOURCE_PATH}/docs/LICENSE.TXT
    ${SOURCE_PATH}/docs/FTL.TXT
    ${SOURCE_PATH}/docs/GPLv2.TXT
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freetype/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/freetype/copyright)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if("bzip2" IN_LIST FEATURES)
        set(USE_BZIP2 ON)
    endif()

    if("png" IN_LIST FEATURES)
        set(USE_PNG ON)
    endif()

    configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/freetype/vcpkg-cmake-wrapper.cmake @ONLY)
endif()
