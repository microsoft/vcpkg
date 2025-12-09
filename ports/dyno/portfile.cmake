vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ldionne/dyno
    REF 56ced251f5751ef4e3fe66d4f28ccbc75b902d70
    SHA512 c3f34679d1e2f3cec3757f69662d4f5db602b9028a927ad9070e70813caf18bb2a512f148e69f14aaac35a3e13abb57e1aa8e4f369993e7a01d048d70050daa6
    HEAD_REF master
    PATCHES fix-deps.patch
)

set(VCPKG_BUILD_TYPE release) #header-only library

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME dyno CONFIG_PATH "lib/cmake/dyno")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
