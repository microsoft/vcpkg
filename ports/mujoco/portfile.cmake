vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deepmind/mujoco
    REF ${VERSION}
    SHA512 dafc848fbda134156f32b1c7668ab95d458e587d10f699ff6f233a03b3cb9e5ae4ceb76df5cc9f7b34d007f4a7419a66f56389e85c4c2cbb2e79a525a63ba557
    PATCHES
        fix_dependencies.patch
        fix-x86-atomic.patch # https://github.com/google-deepmind/mujoco/pull/3358
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
