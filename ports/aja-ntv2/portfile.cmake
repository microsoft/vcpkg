vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aja-video/ntv2
    REF v16.2-bugfix3
    HEAD_REF v16.2
    SHA512 c4e12f4f3d59c37346aae85cac560b3fb5751dd1bba955276d07e6d5e54df9a56607e464cd36ff494c612e00398cd000c952d5fd645c08b9b93f43d8654fcd2f
    PATCHES
        000-ntv2-cmake-export.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DAJA_BUILDING_CMAKE=ON -DAJA_BUILD_DRIVER=OFF -DAJA_BUILD_APPS=OFF
    OPTIONS_RELEASE -DAJA_INSTALL_HEADERS=ON
    )
    
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT} CONFIG_PATH share/unofficial-${PORT})

# No debug headers
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
