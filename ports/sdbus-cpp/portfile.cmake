vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kistler-Group/sdbus-cpp
    REF "v${VERSION}"
    SHA512 bdc628156dc8cc5a1ab0cb08bca8dc58801a233446bc34ce3d10d14b169f8dece16a1204937a674ea80976d9a92da72d72305b8e9ef617a50f7bc5a00c40223a
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
