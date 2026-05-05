vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steinm/pxlib
    REF cd65ac2255a02612a9b2c25bf4f17684ab391d38
    SHA512 c113cf00b876ce4ec28d97b11fb4ace16a6798756fbcb398d0f5a54064cbe03834610925890463356d9ae16514717b4637fa2a87a8f2504ed13703ecd4ce64da
    HEAD_REF master
    PATCHES
        add_cmake_config.patch
        add_extern_c.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_GSF=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-pxlib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
