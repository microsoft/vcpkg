vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO victimsnino/ReactivePlusPlus
    REF "v${VERSION}"
    SHA512 24bc81cf6b26ed994f0740140dedcca2fa794f28e1c59cb6ddb876286a65678dcc849ea7e3ce8d71eb12e1d210eaa2f3e913e0f4e6fc7414e3afaa82c3e0b06a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME RPP CONFIG_PATH share/RPP)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(GLOB_RECURSE CMAKE_LISTS "${CURRENT_PACKAGES_DIR}/include/CMakeLists.txt")
file(REMOVE ${CMAKE_LISTS})

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
