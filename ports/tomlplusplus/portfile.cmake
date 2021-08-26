vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "osx" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF v2.4.0
    SHA512 cfb8a1eeaed3350f8b5341b6893527c9571ee71416c0dc2d680d8739003cd5de85aad8efc0bdbf06e4ed7d3da0a942939509a86c035b551773df3e1b77afacbe
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -Dgenerate_cmake_config=true
        -Dbuild_tests=false
        -Dbuild_examples=false
)

vcpkg_install_meson()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
