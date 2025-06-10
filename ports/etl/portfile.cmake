vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ETLCPP/etl
    REF "${VERSION}"
    SHA512 a12fa4e738f58e859e5e19e63057656a78b36f2cd953f8f6dbf873272d11a74ecd7d03ac5e5c9e3b5b409585eff563a935836e612d43645948d53e2b6ae921cd
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
