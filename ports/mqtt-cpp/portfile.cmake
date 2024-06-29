vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redboltz/mqtt_cpp
    REF v${VERSION}
    SHA512
    70da1f78a032db458b8744d1ed7c3eec97924ad78127ee5aa58cd4fb8e33351874f9d4b2f08aa94a202ee971d3f94d53167da307af3e82b9488aa89796f981e4
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
