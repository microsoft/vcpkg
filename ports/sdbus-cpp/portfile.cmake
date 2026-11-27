vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kistler-Group/sdbus-cpp
    REF "v${VERSION}"
    SHA512 226e601dc2c47f11728fc85e4c07dd2b5db52a4e3e3ffaadaf1be3abbbf7124731a28b1b60690d60d63fa6c8337b6c47df2194267d4ac2d8669647d9d64a98b2
    PATCHES
        dependencies.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool   SDBUSCPP_BUILD_CODEGEN
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSDBUSCPP_BUILD_DOCS=OFF
        -DSDBUSCPP_BUILD_LIBSYSTEMD=OFF
        -DSDBUSCPP_SDBUS_LIB=systemd
    OPTIONS_DEBUG
        -DSDBUSCPP_BUILD_CODEGEN=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sdbus-c++ CONFIG_PATH lib/cmake/sdbus-c++)
vcpkg_fixup_pkgconfig()

if ("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES sdbus-c++-xml2cpp AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

#file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/COPYING-LGPL-Exception")
