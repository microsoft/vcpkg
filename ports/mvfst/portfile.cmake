vcpkg_fail_port_install(ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/mvfst
    REF 497f6e4732bf6e95553d70e24f2e6e1a20c26397 
    SHA512 41bb998f8183839f532c32755572df4a8d38a84ad164011675703a4de73347292b77134fe53359a5622b72c5b1f3fea4b295b8740eda754c860b41f75ba7f751
    HEAD_REF main
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mvfst)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

