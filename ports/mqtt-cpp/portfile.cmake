set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redboltz/mqtt_cpp
    REF "v${VERSION}"
    SHA512
    81e2b6a1d070bb57a212fb95abe3f36f8b41131058675528b67e41a2076a19f30f488619b9e3a5dbc0fe53db4efa5c9959111f06c241ebe616b78a70f9dfcad1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DMQTT_BUILD_EXAMPLES=OFF
    -DMQTT_BUILD_TESTS=OFF
    -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME mqtt_cpp_iface CONFIG_PATH lib/cmake/mqtt_cpp_iface)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
