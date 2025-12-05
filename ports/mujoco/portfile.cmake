vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deepmind/mujoco
    REF ${VERSION}
    SHA512 08ae4c638df552112715d08532087430b9457db67b26f5fd8e0e0ec72d5f195694e19749acbf2553285a57a35a9f1aaa3d19194f3ef125014345d0b7a1372f9c
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
