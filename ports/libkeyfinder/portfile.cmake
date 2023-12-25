vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mixxxdj/libkeyfinder
    REF v2.2.6
    SHA512 c1b771cebfb925db521a344e28fd1d3bc6e6e921e45dcc81f90926e5b2020fea201a4bc05a65177d3559208a45746fd7784eb6f37352bb10ab7d7b820b40c0b6
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME KeyFinder CONFIG_PATH lib/cmake/KeyFinder)
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share")
