vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO victimsnino/ReactivePlusPlus
    REF "v${VERSION}"
    SHA512 426cd5dea6e3a380b86043c2765c74049bff6b1267ed5eb065f766c2e6dee373d6e431e7cf6584c8a9f3109f6ea17a05a03e2a34257695074f0b5daecdb17fbe
    HEAD_REF v2
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
