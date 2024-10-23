vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ETLCPP/etl
    REF "${VERSION}"
    SHA512 27204220da2bc0d6028a689005ebd9150edffae78e6be6beae2ee361e3ef6dce90d1345637fc3ae4f03ef60404de9967ff40c694447c0f85f79772fde39f224f
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
