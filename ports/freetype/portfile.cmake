set(FT_VERSION 2.11.0)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freetype/freetype2
    REF ${FT_VERSION}
    FILENAME freetype-${FT_VERSION}.tar.xz
    SHA512 bf1991f3c382832586be1d21ae73c20840ee8546807ba60d0eb0215134545656c0c8de488f27357d4a4f6497d7cb540998cda98ec59061a3e640036fb209147d
    PATCHES
        0003-Fix-UWP.patch
        fix-2.11-msvc-build.patch
        fix-find-bzip2.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        zlib        zlib
        bzip2       bzip2
        png         png
        brotli      brotli
)

list(TRANSFORM FEATURE_OPTIONS REPLACE "ON" "enabled")
list(TRANSFORM FEATURE_OPTIONS REPLACE "OFF" "disabled")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dharfbuzz=disabled
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

# Rename for easy usage (VS integration; CMake and autotools will not care)
file(RENAME "${CURRENT_PACKAGES_DIR}/include/freetype2/freetype" "${CURRENT_PACKAGES_DIR}/include/freetype")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/freetype2/ft2build.h" "${CURRENT_PACKAGES_DIR}/include/ft2build.h")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/freetype2")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if("zlib" IN_LIST FEATURES)
        set(USE_ZLIB ON)
    endif()

    if("bzip2" IN_LIST FEATURES)
        set(USE_BZIP2 ON)
    endif()

    if("png" IN_LIST FEATURES)
        set(USE_PNG ON)
    endif()

    if("brotli" IN_LIST FEATURES)
        set(USE_BROTLI ON)
    endif()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
endif()

file(COPY
    "${SOURCE_PATH}/docs/FTL.TXT"
    "${SOURCE_PATH}/docs/GPLv2.TXT"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
