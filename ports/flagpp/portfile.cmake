vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/flagpp
    REF "v${VERSION}"
    SHA512 92e324b1cd773ae256c50d389fe1b30ac71237dfb299bae1e413e97b8057433dccb8a6c93ce16f05edc0de624893165491ac621e1b9da9f512df531bd69b504b
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
