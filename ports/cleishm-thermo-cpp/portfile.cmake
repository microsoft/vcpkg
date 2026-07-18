vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cleishm/thermo-cpp
    REF "v${VERSION}"
    SHA512 528456aca2c2bfccab8dbf459c3a66532c67e3ca7fbdff39b014ac7777329b8e570862bc4960ff2b647c518d271380602c7b793e9fff72a017eed395559caab2
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
