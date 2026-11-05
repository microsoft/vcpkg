vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/sanisizer
    REF "v${VERSION}"
    SHA512 1c45035b207fbe5adb4ea070be4df51ec799f419ee2d7c78e2eded188d85e8954de193175493d4f31f5d9dab845f472466d69a329621b7774f3360c1525c81ac
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSANISIZER_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_sanisizer
    CONFIG_PATH lib/cmake/ltla_sanisizer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
