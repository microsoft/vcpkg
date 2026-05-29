vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deepmind/mujoco
    REF ${VERSION}
    SHA512 42931b3ab2c0058f7429dd70c1dd6f82d5a256b28ddd19beb9a74617231d9f735f496bff5e51c2bf2290de11435201e966ea834ff1cb22fa603835aac11f88e0
    PATCHES
        fix_dependencies.patch
        disable-werror.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMUJOCO_BUILD_EXAMPLES=OFF
        -DMUJOCO_BUILD_TESTS=OFF
        -DMUJOCO_TEST_PYTHON_UTIL=OFF
        -DSIMULATE_BUILD_EXECUTABLE=OFF
        -DMUJOCO_SIMULATE_USE_SYSTEM_GLFW=ON
        -DMUJOCO_SIMULATE_USE_SYSTEM_MUJOCO=ON
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_cmake_config_fixup(
        CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
