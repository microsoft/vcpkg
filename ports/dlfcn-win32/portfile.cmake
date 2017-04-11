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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/dlfcn-win32-1.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/dlfcn-win32/dlfcn-win32/archive/v1.1.0.zip"
    FILENAME "dlfcn-win32-v1.1.0.zip"
    SHA512 7ce1d62a3ea927f8ab56c335e975172c5eb0f465b8ba92f1cf1548638ad431214a644da18e1f733e8b9631cb89c277f06ca4d08f87726d5c04c8aa21dee1510f
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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
