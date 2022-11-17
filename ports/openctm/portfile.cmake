vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openctm
    REF OpenCTM-1.0.3
    SHA512 fdfa08d19ecbfea99ba01aa2032e941ed6313394a96bd69f8984c2d2d079d836c616471d2bdf6f40175e75659f3ad0ba41502bc3d8224091472f40893ea8746e
    FILENAME "OpenCTM-1.0.3-src.tar.bz2"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-openctm)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
