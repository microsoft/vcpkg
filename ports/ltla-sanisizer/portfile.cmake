vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/sanisizer
    REF "v${VERSION}"
    SHA512 5842cf30d2f170942914c56b6dde44800127447cb3d1b7c3635dd0f5b0905407a7e735dc31fa42e96ad823bf9f16bf492a9cc7083c826066018ad99009875ec7
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
