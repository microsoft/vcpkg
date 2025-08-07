vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deepmind/mujoco
    REF ${VERSION}
    SHA512 b9862c266c867771a6fbbffbb595684ebaf2c6ae1502718ee2a656e774900094f5e341b212fe8f92646a98da3e431ae4209d8130aee6c41ddc0e33259b8f63ca
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
