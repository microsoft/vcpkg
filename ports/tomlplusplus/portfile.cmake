vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "linux" "osx" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF v2.2.0
    SHA512 e309c10d89d23e379520ed338101ad3d1b48b6184b1475cf9190bace7bd0c0bdcd738ba7dcc66e47183b925c06408ceba5591e8e7fcd419bf7ea6485a07f0679
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
