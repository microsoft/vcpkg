vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO victimsnino/ReactivePlusPlus
    REF "v${VERSION}"
    SHA512 d48e7e0d397c9fea2eef7c7f27f48f80738e814e2418437c367bcb35830baaaef73f570adf8408153bba2736c1f74769bd37ab41e7afbcea81b280112eb5e6b3
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
