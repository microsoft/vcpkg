vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erikerlandson/st_tree
    REF "version_${VERSION}"
    SHA512 b2bd47509783c3efb366343aeb1713874225ba63348afcd1ddc770a4b0ae4d839455cee5e05d4cdc04a5aa798db21c8c9b414492c32d2b1458b2dfcbe87f2388
    HEAD_REF develop
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DENABLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake" PACKAGE_NAME st_tree)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
