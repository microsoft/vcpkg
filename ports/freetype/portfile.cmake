set(FT_VERSION 2.10.2)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freetype/freetype2
    REF ${FT_VERSION}
    FILENAME freetype-${FT_VERSION}.tar.xz
    SHA512 cf45089bd8893d7de2cdcb59d91bbb300e13dd0f0a9ef80ed697464ba7aeaf46a5a81b82b59638e6b21691754d8f300f23e1f0d11683604541d77f0f581affaa
    PATCHES
        0001-Fix-install-command.patch
        0003-Fix-UWP.patch
        pkgconfig.patch
        brotli-static.patch
        fix-exports.patch
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
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/freetype)

# Rename for easy usage (VS integration; CMake and autotools will not care)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/freetype2/freetype ${CURRENT_PACKAGES_DIR}/include/freetype)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/freetype2/ft2build.h ${CURRENT_PACKAGES_DIR}/include/ft2build.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/freetype2)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Fix the include dir [freetype2 -> freetype]
file(READ ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-targets.cmake CONFIG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}/include/freetype2" "\${_IMPORT_PREFIX}/include" CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlicommon-static.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlicommon-static.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlicommon-static.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlidec-static.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlidec-static.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlidec-static.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlidec.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlidec.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlidec.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlidec.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlidec.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlidec.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-targets.cmake "${CONFIG_MODULE}")

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

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if("bzip2" IN_LIST FEATURES)
        set(USE_BZIP2 ON)
    endif()

    if("png" IN_LIST FEATURES)
        set(USE_PNG ON)
    endif()

    configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake 
        ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)
endif()

file(COPY
    ${SOURCE_PATH}/docs/FTL.TXT
    ${SOURCE_PATH}/docs/GPLv2.TXT
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)
file(INSTALL ${SOURCE_PATH}/docs/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
