vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO johnwason/drekar-launch-process-cpp
    REF v0.1.0
    SHA512 5f2d9e9c8a6f9e2884441fdc6369441d5ad0e13c40412fc8f64043ba614b0abc86e34405dd75e8ea7760e5ca7a2c1457ef52c5b082db16645f7158f74a56872e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT} )

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
