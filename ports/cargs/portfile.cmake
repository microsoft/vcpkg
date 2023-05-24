vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO likle/cargs
    REF v1.0.3
    SHA512 4f82f6857af6ae7bd1263f4c812a770fa3c3f94c84d5a0ba6256289a3d3084cd35b3aca6769241451d2acd57577ccc6638327b5bb70328800e9c3c4f5054f7de
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cargs)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
