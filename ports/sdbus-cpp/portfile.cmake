message(WARNING "You will need to install sytemd dependencies to build sdbus-cpp:\nsudo apt install libsystemd-dev\n")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kistler-Group/sdbus-cpp
    REF "v${VERSION}"
    SHA512 638453d2ea0d5ba556eacda59ca114896bf275d227b33b525259bf69dac3d766df6586046e6ea83a8c1afe9fb0701f4d358819ed9300bab598e775a0a2880917
)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool   SDBUSCPP_BUILD_CODEGEN
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DSDBUSCPP_BUILD_LIBSYSTEMD=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sdbus-c++ CONFIG_PATH lib/cmake/sdbus-c++)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/COPYING-LGPL-Exception")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if ("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES sdbus-c++-xml2cpp AUTO_CLEAN)
endif()
