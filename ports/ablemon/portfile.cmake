# abLEMON at the tag of its version, built without the LP and MIP backends,
# the tests, the demos, the tools and the documentation

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmeoli/abLEMON
    REF ${VERSION}
    SHA512 ff451270c8817015931b83a769e0cf78bd4d0d6b361cde59f43010c1a429fef4cff429793038143ea808ac00737646a45097cc7d90e4eaefa4995df1fb6f5c4a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLEMON_VERSION=${VERSION}
        -DLEMON_BUILD_TESTS=OFF
        -DLEMON_BUILD_DEMOS=OFF
        -DLEMON_BUILD_TOOLS=OFF
        -DLEMON_BUILD_DOC=OFF
        -DLEMON_ENABLE_GLPK=OFF
        -DLEMON_ENABLE_ILOG=OFF
        -DLEMON_ENABLE_COIN=OFF
        -DLEMON_ENABLE_SOPLEX=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/lemon/cmake PACKAGE_NAME lemon)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE"
                             "${SOURCE_PATH}/lemon/random.h")
# after the copyright, which makes share/${PORT}
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage-accurate")
