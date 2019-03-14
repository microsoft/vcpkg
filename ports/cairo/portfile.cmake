include(vcpkg_common_functions)
set(CAIRO_VERSION 1.17.2)

vcpkg_download_distfile(ARCHIVE
    URLS "http://cairographics.org/snapshots/cairo-${CAIRO_VERSION}.tar.xz"
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
		0002_steal-boxes-Fix-an-invalid-free.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/src)
file(COPY ${CURRENT_PORT_DIR}/cairo-features.h DESTINATION ${SOURCE_PATH}/src)

vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH ${SOURCE_PATH}/src
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-cairo TARGET_PATH share/unofficial-cairo)

# Copy the appropriate header files.
foreach(FILE
"${SOURCE_PATH}/src/cairo.h"
"${SOURCE_PATH}/src/cairo-deprecated.h"
"${SOURCE_PATH}/src/cairo-features.h"
"${SOURCE_PATH}/src/cairo-pdf.h"
"${SOURCE_PATH}/src/cairo-ps.h"
"${SOURCE_PATH}/src/cairo-script.h"
"${SOURCE_PATH}/src/cairo-svg.h"
"${SOURCE_PATH}/cairo-version.h"
"${SOURCE_PATH}/src/cairo-win32.h"
"${SOURCE_PATH}/util/cairo-gobject/cairo-gobject.h"
"${SOURCE_PATH}/src/cairo-ft.h")
  file(COPY ${FILE} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
  file(COPY ${FILE} DESTINATION ${CURRENT_PACKAGES_DIR}/include/cairo)
endforeach()

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
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/cairo)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cairo/COPYING ${CURRENT_PACKAGES_DIR}/share/cairo/copyright)

vcpkg_copy_pdbs()

vcpkg_test_cmake(PACKAGE_NAME unofficial-cairo)
