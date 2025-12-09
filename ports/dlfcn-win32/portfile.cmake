
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dlfcn-win32/dlfcn-win32
    REF "v${VERSION}"
    SHA512 13b52c078c20f97b4293257904d64c4a018115a68af606a04699acbe3f7ff07887eecd2512363c062eb43a34cedd27c5989bded4b7d0530d697dbd65dbdbffac
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
