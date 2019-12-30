vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mmahnic/argumentum
    REF v0.2.1
    SHA512 e2d452b5e4aa37a5b76b14ac905e040e1f0791aa687f912addcf949c64747aee21273a345a99851f64c9fad337cd11f74c408a3c6455346c30eea1aaee2244a6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DARGUMENTUM_BUILD_EXAMPLES=OFF
        -DARGUMENTUM_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Argumentum)

vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)
