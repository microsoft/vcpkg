vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/rebind
    REF "v${VERSION}"
    SHA512 3b0fba09f8bd6257c055a6619094646c70e90fbb55967165dd94eb1914c1477443a86e5745c08a4dd722656ab124fffcbaabbd9d2b8ec82be30d741799eff93d
    HEAD_REF master
    PATCHES
        remove-cpm.patch # Note: Removed also the ALIAS library as packageProject creates it
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
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/${PORT}-${VERSION}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
