# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(CAIRO_VERSION 1.15.6)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cairo-${CAIRO_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://cairographics.org/snapshots/cairo-${CAIRO_VERSION}.tar.xz"
    FILENAME "cairo-${CAIRO_VERSION}.tar.xz"
    SHA512 e4eccba745a03545001ebd6f1a7b87bee4b932f80a2d877a764500ad5c18011a5bac585f31eec6d0b65ccaa818de0df2b3b99f0792111363bd3554cfa7f688b6
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/Initialize-mutexes-for-static-builds-for-win32.patch"
            "${CMAKE_CURRENT_LIST_DIR}/export-only-in-shared-build.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/src)
file(COPY ${CURRENT_PORT_DIR}/cairo-features.h DESTINATION ${SOURCE_PATH}/src)

vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH ${SOURCE_PATH}/src
)

vcpkg_install_cmake()

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
