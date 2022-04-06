set(SOURCE_VERSION 1.1.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dlfcn-win32/dlfcn-win32
    REF v${SOURCE_VERSION}
    SHA512 557729511546f574487f8c7de437c53bcf5ae11640349c338ead9965a4ac0f937de647839b63c821003be54dca5bcbf28f2899d2348acf7dfef31e487da1cba1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(READ "${CURRENT_PACKAGES_DIR}/debug/share/dlfcn-win32/dlfcn-win32-targets-debug.cmake" dlfcn-win32_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" dlfcn-win32_DEBUG_MODULE "${dlfcn-win32_DEBUG_MODULE}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/dlfcn-win32/dlfcn-win32-targets-debug.cmake" "${dlfcn-win32_DEBUG_MODULE}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)


set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
