vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "osx" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF v2.3.0
    SHA512 3a6328f71953baca25cb29bb493605e964496d1bc39961679cd97f72feecad63a21d6ebd9fe51b6e1b9b185a35581cb3fb199f6b0cc643b5b782bdd85249b79e
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
