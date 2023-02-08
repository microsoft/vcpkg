vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-dis/open-dis-cpp
    REF "v${VERSION}"
    SHA512 e6d38f55beabf85d0319be21d9cec07f818b833dfa14dcb649cacbc8ea86779c29ac2717579239378ace1ae62054864851ecb55402e82fe4d083ab483218260e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME OpenDIS CONFIG_PATH lib/cmake/OpenDIS)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
