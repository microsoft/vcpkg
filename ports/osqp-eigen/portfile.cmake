vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "robotology/osqp-eigen"
    REF v0.7.0     
    SHA512 92a801892ce11d3167e3f1eb98cd988e7be7cbc3caa070b1628977b7d881b34c1207d9c1443ba381d88be4133bda6d3e9195c931f9554537c86832841f1e61fb 
    PATCHES osqp-eigen.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME  "osqpeigen" CONFIG_PATH "lib/cmake/OsqpEigen")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
