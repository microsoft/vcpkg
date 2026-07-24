vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-dis/open-dis-cpp
    REF "v${VERSION}"
    SHA512 7403570f0d2f9c57b130a318d75b39bf07e4db6688c9219f1c0350c5734232a2b26a7952a392a5cb53a7e8bf0e71f151c7eb63b6ad583fcda6c2b46d92b4cd02
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
