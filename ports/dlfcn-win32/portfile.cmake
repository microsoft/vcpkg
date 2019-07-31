# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_VERSION 1.1.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/dlfcn-win32-${SOURCE_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/dlfcn-win32/dlfcn-win32/archive/v${SOURCE_VERSION}.zip"
    FILENAME "dlfcn-win32-v${SOURCE_VERSION}.zip"
    SHA512 581043784d8c1b1b43c88c0da302f79d70e1d33e95977a355d849b8f8c45194b55fdc28e36a3f3ed192eca8fee6b00cb8bf1d1d1fc08b94d53be6f73bea6e09a
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/dlfcn-win32/dlfcn-win32-targets-debug.cmake dlfcn-win32_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" dlfcn-win32_DEBUG_MODULE "${dlfcn-win32_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/dlfcn-win32/dlfcn-win32-targets-debug.cmake "${dlfcn-win32_DEBUG_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/dlfcn-win32)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/dlfcn-win32/COPYING ${CURRENT_PACKAGES_DIR}/share/dlfcn-win32/copyright)
