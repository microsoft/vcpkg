vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/nameof
    REF "v${VERSION}"
    SHA512 82c9464eaf23000b2e533b9eacaf241da71a73e8baa09452dfade8aa449169352f20c66cf7c1e0b5e98ac92cc72af9de2fb6e985e64276997656bbbaae48cf69
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNAMEOF_OPT_BUILD_EXAMPLES=OFF
        -DNAMEOF_OPT_BUILD_TESTS=OFF
        -DNAMEOF_OPT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
