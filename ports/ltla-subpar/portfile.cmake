vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/subpar
    REF "v${VERSION}"
    SHA512 00630123dc805d6be7626a8ee7ef87f8e54e37245a6eebc9e5b7af72a50a0d2df130c218e6f77216a169ea6933ba75cd7b87b55673063d3698886aa4c120a143
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSUBPAR_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_subpar
    CONFIG_PATH lib/cmake/ltla_subpar
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
