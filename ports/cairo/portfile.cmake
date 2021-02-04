set(CAIRO_VERSION 1.17.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/snapshots/cairo-${CAIRO_VERSION}.tar.xz"
    FILENAME "cairo-${CAIRO_VERSION}.tar.xz"
    SHA512 7219833039f001cb6fca390b68771041a572ff450b4b18e309fa11d1b4d949a7d57d74d7a7d7ff7f2188cbd3188f00b5cdb2ffe4fd5b1ec33a56cfb3aea952de
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${CAIRO_VERSION}
    PATCHES
        export-only-in-shared-build.patch
        0001_fix_osx_defined.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/src)

if("freetype" IN_LIST FEATURES)
    set(CAIRO_HAS_FT_FONT TRUE)
    set(CAIRO_HAS_FC_FONT TRUE)
endif()
configure_file("${CMAKE_CURRENT_LIST_DIR}/cairo-features.h.in" "${SOURCE_PATH}/src/cairo-features.h")

if ("x11" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Feature x11 only support UNIX.")
    endif()
    message(WARNING "You will need to install Xorg dependencies to use feature x11:\napt install libx11-dev libxft-dev\n")
endif()

if("gobject" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        message(FATAL_ERROR "Feature gobject currently only supports dynamic build.")
    endif()
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    x11 WITH_X11
    gobject WITH_GOBJECT
    freetype WITH_FREETYPE
)

vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH ${SOURCE_PATH}/src
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-cairo TARGET_PATH share/unofficial-cairo)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

foreach(FILE "${CURRENT_PACKAGES_DIR}/include/cairo.h" "${CURRENT_PACKAGES_DIR}/include/cairo/cairo.h")
    file(READ ${FILE} CAIRO_H)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined (CAIRO_WIN32_STATIC_BUILD)" "1" CAIRO_H "${CAIRO_H}")
    else()
        string(REPLACE "defined (CAIRO_WIN32_STATIC_BUILD)" "0" CAIRO_H "${CAIRO_H}")
    endif()
    file(WRITE ${FILE} "${CAIRO_H}")
endforeach()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
