vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ladislav-zezula/StormLib
    REF "v${VERSION}"
    SHA512 5f0ce75019cfbe3a2dfc07ea312825e2babf226dbf8aa77ed60456862ae739ac4689cbe7d4a185cdc148ad9910fd8137d3f11c04ffe6c532bbdacb08838ecfba
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
