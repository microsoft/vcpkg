
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dlfcn-win32/dlfcn-win32
    REF "v${VERSION}"
    SHA512 2ddcaad7fff09be654589642af14689ebbc15212caea5b5fb0238b34188c87cd9cb53d7aee45c7ae4dd6ddf6e637ee945567d7b858b97ceefff8f1ec46b786ae
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
