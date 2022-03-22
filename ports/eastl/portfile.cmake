vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF e8bdd5531ed79c30ccef2fd71e070f5ab9f1222a #v3.18.00
    SHA512 3e5d97a77b8610a2efdb9156b47c91e8a8dd5629ff95ea6d2c65016b067ab645df5beddc8c7f93d89c3d1a6f404ff71282efc6db9885a6e6240fa444fe2be79c
    HEAD_REF master
    PATCHES 
        fix_cmake_install.patch
        Fix-error-C2338.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/EASTLConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEASTL_BUILD_TESTS=OFF
        -DEASTL_BUILD_BENCHMARK=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/EASTL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/3RDPARTYLICENSES.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# CommonCppFlags used by EAThread
file(INSTALL "${SOURCE_PATH}/scripts/CMake/CommonCppFlags.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
