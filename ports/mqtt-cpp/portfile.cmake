vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redboltz/mqtt_cpp
    REF v13.0.0    
    SHA512
2f0c85ac813cc6c99cc5b1ca02514ee6643abc39750bce541a362d1fcd281b8b9011cc39ddeaf4394fd3772904eed15e8ecbe6b3839caad13cae2b04201e682b
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(
    INSTALL "${SOURCE_PATH}/LICENSE_1_0.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
