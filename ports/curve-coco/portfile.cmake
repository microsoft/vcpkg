set(VCPKG_BUILD_TYPE release) # Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/coco
    REF "v${VERSION}"
    SHA512 7c011553834dba0030ad01d45fcdd3b092ca1b30ccb6f500bbc3e53ed5ee3c0eb57a581347f9879e5b3746cdc3e3214d41329a6ef04988c64c9f55350d8948a3
    HEAD_REF master
    PATCHES
        remove-cpm.patch
)

# Replace CPM and download PackageProject directly to avoid issues with FETCHCONTENT_FULLY_DISCONNECTED
vcpkg_from_github(
    OUT_SOURCE_PATH PACKAGE_PROJECT_PATH
    REPO TheLartians/PackageProject.cmake
    REF "v1.13.0"
    SHA512 3cf0523bddc213f206ed0ca57803550cb7db9e293392d3741138be47f49d9027ef517e1656235a349a62b492d35c3fc677714dc00afe59e2d36144a9689cfa8f
    HEAD_REF master
)
file(RENAME "${PACKAGE_PROJECT_PATH}" "${SOURCE_PATH}/cmake/packageproject.cmake")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/coco-${VERSION}" PACKAGE_NAME "coco")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")  # from CMake config

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
