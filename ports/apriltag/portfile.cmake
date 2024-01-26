if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AprilRobotics/apriltag
    REF v${VERSION}
    SHA512 0b09b530ed03dce0bdc3c4e08b17d98f1303ab1d45870843354bf1a5bdf6c7efc6089e2bdf40a370d17a8191b7ce2c46fefa2dd2d49a959591351e00e186f33e
    HEAD_REF master
    PATCHES
        fix-config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)
vcpkg_fixup_pkgconfig()

if (VCPKG_TARGET_IS_WINDOWS)
    file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}Config.cmake" FIXED_CONFIG)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}Config.cmake" "
    include(CMakeFindDependencyMacro)
    find_dependency(PThreads4W)
    ${FIXED_CONFIG}
    ")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
