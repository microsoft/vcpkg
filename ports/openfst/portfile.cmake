vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kkm000/openfst
    REF 338225416178ac36b8002d70387f5556e44c8d05 #1.7.2
    SHA512 14e1ac44ff5d059dc12ab0412037744a207e54485443dbf6eab4e6fb4aab122bbbcbd54af3ce23732c7d960448756c5a5ec0e116e0a797fa343156bb865f3eb1
    HEAD_REF winport
    PATCHES
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME openfst CONFIG_PATH share/openfst)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
