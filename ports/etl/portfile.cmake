vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ETLCPP/etl
    REF "${VERSION}"
    SHA512 3d34987db589bbf071a4359b65322a0c25b1c66d2bdc00f0906656f8c381ebe3288ee6cebeb22301a921c95a6486d6143fd8ecae75e3912de75760cb7c4e792b
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/etl/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/etl/.vscode")
# remove templates used for generating headers
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/etl/generators")
file(GLOB_RECURSE PNG_FILES "${CURRENT_PACKAGES_DIR}/include/etl/*.png")
file(REMOVE ${PNG_FILES})

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
