vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AndrewGaspar/corrosion
    REF v0.2.2
    SHA512 ea4b4054658e7c6f8ac0aea1c12f97965fa8101de37310df8069fa24481e221683148ec0347fd3135e35b0c10695b698429a8f57d1b22ffc1c224bb671f97465
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCORROSION_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

# corrosion is a cmake only port
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_cmake_config_fixup(PACKAGE_NAME Corrosion CONFIG_PATH lib/cmake/Corrosion)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
