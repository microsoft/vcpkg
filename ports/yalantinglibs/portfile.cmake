set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 171930433/yalantinglibs
    REF "${VERSION}"
    SHA512 acde5540f309b7cef2df9b1fc253b9d6b0abedec3a646332599fa83b32284b34a3a970546605e0e6b5e375e4b52e799a990ad962d8f4f271ffee3d4c5b1b1b65
    HEAD_REF main
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DBUILD_BENCHMARK=OFF
      -DBUILD_EXAMPLES=OFF
      -DBUILD_UNIT_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/yalantinglibs")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
