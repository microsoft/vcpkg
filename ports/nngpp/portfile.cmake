vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cwzx/nngpp
    REF 85294eda3f584281439649a074f46e2d3516b2a1
    SHA512 8f794c323a4cefe67b525652480154bbd6b8ca205f37de04ee1a14fc56b794a754972931c85dc5a1969b6fc626ef6b7f1a2682ac9cd627c86b2e811a5c077c0e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNNGPP_BUILD_DEMOS=OFF
        -DNNGPP_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

