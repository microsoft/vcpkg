vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "linux" "osx" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF v1.3.0
    SHA512 3c758c59f4bddfc646b596c358909f37c35d3e7200bd04663bf8c6493c2f64797352dd8a788e68bcc1a785fa41ac2dfc5621bf5328018748bdc3c5cea621b3bc
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DGENERATE_CMAKE_CONFIG=enabled
            -DBUILD_TESTS=disabled
            -DBUILD_EXAMPLES=disabled
)

vcpkg_install_meson()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
