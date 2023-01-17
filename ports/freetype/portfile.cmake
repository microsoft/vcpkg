set(FT_VERSION 2.12.1)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freetype/freetype2
    REF ${FT_VERSION}
    FILENAME freetype-${FT_VERSION}.tar.xz
    SHA512 6482de1748dc2cc01e033d21a3b492dadb1f039d13d9179685fdcf985e24d7f587cbca4c27ed8a7fdb7d9ad59612642ac5f4db062443154753295363f45c052f
    PATCHES
        0003-Fix-UWP.patch
        brotli-static.patch
        bzip2.patch
        fix-exports.patch
        error-strings.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        zlib          FT_REQUIRE_ZLIB
        bzip2         FT_REQUIRE_BZIP2
        error-strings FT_ENABLE_ERROR_STRINGS
        png           FT_REQUIRE_PNG
        brotli        FT_REQUIRE_BROTLI
    INVERTED_FEATURES
        zlib          FT_DISABLE_ZLIB
        bzip2         FT_DISABLE_BZIP2
        png           FT_DISABLE_PNG
        brotli        FT_DISABLE_BROTLI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFT_DISABLE_HARFBUZZ=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/freetype)

# Rename for easy usage (VS integration; CMake and autotools will not care)
file(RENAME "${CURRENT_PACKAGES_DIR}/include/freetype2/freetype" "${CURRENT_PACKAGES_DIR}/include/freetype")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/freetype2/ft2build.h" "${CURRENT_PACKAGES_DIR}/include/ft2build.h")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/freetype2")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Fix the include dir [freetype2 -> freetype]
file(READ "${CURRENT_PACKAGES_DIR}/share/freetype/freetype-targets.cmake" CONFIG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}/include/freetype2" "\${_IMPORT_PREFIX}/include" CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlicommon-static.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlicommon-static.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlicommon-static.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlidec-static.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlidec-static.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlidec-static.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlidec.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlidec.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlidec.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/brotlidec.lib" [[\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/brotlidec.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/brotlidec.lib>]] CONFIG_MODULE "${CONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-targets.cmake "${CONFIG_MODULE}")

find_library(FREETYPE_DEBUG NAMES freetyped PATHS "${CURRENT_PACKAGES_DIR}/debug/lib/" NO_DEFAULT_PATH)
if(NOT VCPKG_BUILD_TYPE)
    file(READ "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freetype2.pc" _contents)
    if(FREETYPE_DEBUG)
        string(REPLACE "-lfreetype" "-lfreetyped" _contents "${_contents}")
    endif()
    string(REPLACE "-I\${includedir}/freetype2" "-I\${includedir}" _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freetype2.pc" "${_contents}")
endif()

file(READ "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freetype2.pc" _contents)
string(REPLACE "-I\${includedir}/freetype2" "-I\${includedir}" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freetype2.pc" "${_contents}")


vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.TXT"
        "${SOURCE_PATH}/docs/FTL.TXT"
        "${SOURCE_PATH}/docs/GPLv2.TXT"
)
