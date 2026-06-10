vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ladislav-zezula/StormLib
    REF "v${VERSION}"
    SHA512 5d989c02516e100eae9102080fd72053601f7e284fc38f0359cb7386b9d2e8bcc3768454e2d818085584971a986bebed3daf28b85d924c172417a82fae64c02a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME StormLib)
vcpkg_copy_pdbs()


file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
