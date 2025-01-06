vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deepmind/mujoco
    REF ${VERSION}
    SHA512 40e73339b65f051e9774f5d7f8ca0984b5bdce52fcb46a5e5a8449efc09d7eb5441b918d07ebd8b5cf2f69616ff1a8e32d6b5dab76c9440da1a5e6ce3328c261
    PATCHES
        fix_dependencies.patch
        fix_x86.patch
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
