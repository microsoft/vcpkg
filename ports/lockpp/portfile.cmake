vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/lockpp
    REF "v${VERSION}"
    SHA512 0581718dc2451d3cc62f2d0443f52a1adc95fe7a8ee859bd9cca78d68aa029ce7bc9e5387eca24f1b5fe44fc4af3ec662426c471b16e5ad0f29aa83ae0d2c4c1
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/lockpp-${VERSION}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
