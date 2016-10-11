# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/harfbuzz-1.3.2)
find_program(NMAKE nmake)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-1.3.2.tar.bz2"
    FILENAME "harfbuzz-1.3.2.tar.bz2"
    SHA512 19f846ee75d8a2d94da2a2b489fa8e54a5120599f998e451187f6695aa3931b28c491bbc0837892eaaebbd1da3441effe01f5f2470454f83cfa6a7c510ebcb32
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.vc CFG=debug
    WORKING_DIRECTORY ${SOURCE_PATH}/win32/
    LOGNAME nmake-build-${TARGET_TRIPLET}-debug
)

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.vc CFG=release
    WORKING_DIRECTORY ${SOURCE_PATH}/win32/
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" NATIVE_PACKAGES_DIR_DBG)

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.vc CFG=debug PREFIX=${NATIVE_PACKAGES_DIR_DBG} install
    WORKING_DIRECTORY ${SOURCE_PATH}/win32/
    LOGNAME nmake-install-${TARGET_TRIPLET}-debug
)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR_REL)

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.vc CFG=release PREFIX=${NATIVE_PACKAGES_DIR_REL} install
    WORKING_DIRECTORY ${SOURCE_PATH}/win32/
    LOGNAME nmake-install-${TARGET_TRIPLET}-release
)

# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/harfbuzz-1.3.2/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/harfbuzz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/harfbuzz/COPYING ${CURRENT_PACKAGES_DIR}/share/harfbuzz/copyright)
