vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/coco
    REF "v${VERSION}"
    SHA512 b2ed5eaddbbec115d61fc044c6ac56cfef67e871bd44e4717cd64c998a2038195a5caa70e3351efc2c04ccbc69834ffd2e6bbe15331521a1cd33b19155534c7b
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
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/coco" PACKAGE_NAME "coco")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
