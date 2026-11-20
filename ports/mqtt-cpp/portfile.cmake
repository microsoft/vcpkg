set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redboltz/mqtt_cpp
    REF "v${VERSION}"
    SHA512
    986cf79174255521055e59b95ecb5bee72626af2e4ab0ca545387d30f8328aeef5055c263db11b76024100e17ac399e03bf8cc2578f4078d2f299091758cf788
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
