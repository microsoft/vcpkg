# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/harfbuzz-1.3.4)
find_program(NMAKE nmake)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-1.3.4.tar.bz2"
    FILENAME "harfbuzz-1.3.4.tar.bz2"
    SHA512 72027ce64d735f1f7ecabcc78ba426d6155cebd564439feb77cefdfc28b00bfd9f6314e6735addaa90cee1d98cf6d2c0b61f77b446ba34e11f7eb7cdfdcd386a
)
vcpkg_extract_source_archive(${ARCHIVE})

file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include" FREETYPE_INCLUDE_DIR)
file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/lib" FREETYPE_LIB_DIR_DBG)
file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib" FREETYPE_LIB_DIR_REL)

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.vc CFG=debug FREETYPE=1 FREETYPE_DIR=${FREETYPE_INCLUDE_DIR} ADDITIONAL_LIB_DIR=${FREETYPE_LIB_DIR_DBG}
    WORKING_DIRECTORY ${SOURCE_PATH}/win32/
    LOGNAME nmake-build-${TARGET_TRIPLET}-debug
)

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.vc CFG=release FREETYPE=1 FREETYPE_DIR=${FREETYPE_INCLUDE_DIR} ADDITIONAL_LIB_DIR=${FREETYPE_LIB_DIR_REL}
    WORKING_DIRECTORY ${SOURCE_PATH}/win32/
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" NATIVE_PACKAGES_DIR_DBG)

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.vc CFG=debug FREETYPE=1 PREFIX=${NATIVE_PACKAGES_DIR_DBG} install
    WORKING_DIRECTORY ${SOURCE_PATH}/win32/
    LOGNAME nmake-install-${TARGET_TRIPLET}-debug
)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR_REL)

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.vc CFG=release FREETYPE=1 PREFIX=${NATIVE_PACKAGES_DIR_REL} install
    WORKING_DIRECTORY ${SOURCE_PATH}/win32/
    LOGNAME nmake-install-${TARGET_TRIPLET}-release
)

# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/harfbuzz-1.3.4/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/harfbuzz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/harfbuzz/COPYING ${CURRENT_PACKAGES_DIR}/share/harfbuzz/copyright)
