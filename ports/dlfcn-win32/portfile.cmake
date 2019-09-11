include(vcpkg_common_functions)
set(SOURCE_VERSION 1.1.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dlfcn-win32/dlfcn-win32
    REF v${SOURCE_VERSION}
    SHA512 581043784d8c1b1b43c88c0da302f79d70e1d33e95977a355d849b8f8c45194b55fdc28e36a3f3ed192eca8fee6b00cb8bf1d1d1fc08b94d53be6f73bea6e09a
    HEAD_REF master
)

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

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
