include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danielaparker/jsoncons
    REF v0.131.2
    SHA512 7053a971cbc6e12623b65f98323c0d330c903f2b5eae9191369a9a04ae87654e8fa435139e9a72829a1ef9a957e3d4837362c90668f42ba8a0eedc80207e6eef
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
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jsoncons)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jsoncons/LICENSE ${CURRENT_PACKAGES_DIR}/share/jsoncons/copyright)
