vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/ereignis
    REF "v${VERSION}"
    SHA512 f6a00270d02533aab41b3bddee0d7af8fc46e2f17bf832f7aa293a175631c4ed1ec92a345f7175d0785c90966d10bb0a4f8fba059e2d25eff2fdb357b8d64201
    HEAD_REF master
    PATCHES
        remove-cpm.patch
)

file(WRITE "${SOURCE_PATH}/cmake/CPM.cmake" "# disabled by vcpkg")

# Replace CPM and download PackageProject directly to avoid issues with FETCHCONTENT_FULLY_DISCONNECTED
vcpkg_from_github(
    OUT_SOURCE_PATH PACKAGE_PROJECT_PATH
    REPO TheLartians/PackageProject.cmake
    REF "v1.13.0"
    SHA512 3cf0523bddc213f206ed0ca57803550cb7db9e293392d3741138be47f49d9027ef517e1656235a349a62b492d35c3fc677714dc00afe59e2d36144a9689cfa8f
    HEAD_REF master
)
file(RENAME "${PACKAGE_PROJECT_PATH}" "${SOURCE_PATH}/cmake/packageproject.cmake")

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/ereignis-${VERSION})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
