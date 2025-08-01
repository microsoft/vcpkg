vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kaaserne/cpp-lazy
    REF "${VERSION}"
    SHA512 9ca34fc3c532602e1e92480080a020eb9f44de751159f9fd028552413f15f08f9705898eacb306668ab3cb243bb629b7f9e68078a0fcd882b886154b6bd69430
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME cpp-lazy CONFIG_PATH lib/cmake/cpp-lazy)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
