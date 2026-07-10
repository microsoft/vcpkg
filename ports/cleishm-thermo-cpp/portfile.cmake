vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cleishm/thermo-cpp
    REF "v${VERSION}"
    SHA512 59053c3bbfd025023b66eca6dc4f849bd0e80e04e832885d6169c6da41a619cd8262846773c4f4b14801c39fbe665a4da345c4a2449a43636f28db1654527b05
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTHERMO_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME thermo CONFIG_PATH lib/cmake/thermo)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
