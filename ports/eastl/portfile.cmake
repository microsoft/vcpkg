vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF 41bd2e4466e33b979d2afc37f9b98dacf1eab50b #v 3.17.03
    SHA512 3011a0a08701b683e22cc624167b4f65fce8b16d0f7a03675f6a1d5b02313c5b763bcc6c8091f65728ed60ceee8d585cbdb1968a35fb24954f4f66afabb23865
    HEAD_REF master
    PATCHES 
        fix_cmake_install.patch
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
