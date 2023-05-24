vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svi-opensource/libics
    REF ae55128e0532d78aaea4adce21a3fa553d208b83 # 1.6.5
    SHA512 37a1e9034d7e32954840e18f3e3c19f6ed2f8c651ce0da53f678e2f04653be0fc4d9ab3dca8b6f0bfcaec2a9cc560ccfbc7d9034977faa14036281d6a3ca662a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/GNU_LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
