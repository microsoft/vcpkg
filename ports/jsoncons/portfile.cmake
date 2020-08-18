vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danielaparker/jsoncons
    REF 41302e394917a71e7e73db9a50f7d496d2862fd3 # v0.153.3
    SHA512 8b1859f484eada1db02c7f146efd1a53b412f06e4b4c2b0a1aaf4b96242a839093c5eb5b588e1e29b56830223e07b6d0b6418cca616d901316d9cb30de4e803e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
