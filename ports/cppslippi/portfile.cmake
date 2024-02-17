vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            cppslippi
    FILENAME        "CppSlippi-${VERSION}.zip"
    SHA512          88b58e15a18c4d3dfd3d79098db45f7ef4ab8fc1b27329920f4e2c55971a3c67ef81ec013112875b1c944a3a939af7ab8684c2ad253af1e175ea5e2c1e69fd69
    NO_REMOVE_ONE_LEVEL
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=False
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CppSlippi)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
