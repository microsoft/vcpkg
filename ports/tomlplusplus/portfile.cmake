vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "linux" "osx" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF v2.1.0
    SHA512 7bd0ea4ecfc90946487acd545bc8635a85353506c90553f4a6f8e3d83c30f85ac12e1ce82c10e03a4ea335c1b622e64ea0753efca9b2829907996e3a6d28867a
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DGENERATE_CMAKE_CONFIG=enabled
        -DBUILD_TESTS=disabled
        -DBUILD_EXAMPLES=disabled
)

vcpkg_install_meson()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
