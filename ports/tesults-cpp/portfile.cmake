vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesults/cpp
    REF "v${VERSION}"
    SHA512 961d7f69fb00b57deceb4f2660394229437c63f4b4e23f266b6db8abe5183ff84e996312bd005ff22c496499269e81508faacc1119fd2394613a1a51d601bdaf
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tesults)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
