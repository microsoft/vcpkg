set(SOURCE_VERSION 1.3.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dlfcn-win32/dlfcn-win32
    REF v${SOURCE_VERSION}
    SHA512 0aa01c49ee8628c42cdc8b9782b4741a36502764d4442227ea4e9a8062356ff17e8eaa3cdd4113009ad7ad2044b6cfd24128319d71825e13062259dd1906e27e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
