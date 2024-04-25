vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EAThread
    REF e4367a36f2e55d10b2b994bfbae8edf21f15bafd
    SHA512 cd5a2aa6cdfe6fa538067919aa49e5ecd901898e12929dc852068ce66efe386032eb1fe667ea7d9b7a3d73a7bef1d90a683c0b90b6fb0d6d9a27950b05c4ab6a
    HEAD_REF master
    PATCHES
    fix_cmake_install.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/EAThreadConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DEATHREAD_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/EAThread)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/3RDPARTYLICENSES.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/eathread")
