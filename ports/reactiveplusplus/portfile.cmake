vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO victimsnino/ReactivePlusPlus
    REF v0.2.2
    SHA512 86c374c7523c028528ce985f053901a1f0f37a18c2d16085a60fd5d0819ae052cc3d6bfe6065627044b51e65b24de93399be9ba6f0ca8ec92622358112f1c821
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
