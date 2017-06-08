# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cairo-1.15.4)
vcpkg_download_distfile(ARCHIVE
    URLS "http://cairographics.org/snapshots/cairo-1.15.4.tar.xz"
    FILENAME "cairo-1.15.4.tar.xz"
    SHA512 ac3e6879fcf0876bca9f801cdf9e970ef1822644228cdd21962d0bf5db5fc074973f4ae651eb9c76b44fffd405cf0a0c7cbb228dba96b835ea137a2740277ee9
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists_cairo.txt DESTINATION ${SOURCE_PATH}/src)
file(RENAME ${SOURCE_PATH}/src/CMakeLists_cairo.txt ${SOURCE_PATH}/src/CMakeLists.txt)
file(COPY ${CURRENT_PORT_DIR}/cairo-features.h DESTINATION ${SOURCE_PATH}/src)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
    )
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
    )
endif()

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

foreach(FILE "${CURRENT_PACKAGES_DIR}/include/cairo.h")
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
