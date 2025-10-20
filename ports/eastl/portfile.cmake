vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF "${VERSION}"
    SHA512 b061660b58aea8944b7b1488bbf344d004a93a06c89fa43881a02cdaf9d0fce5db3db3c5efd9c09e3e000b502c5dc197ab57b298d1bc935fc7603d285f8563db
    HEAD_REF master
    PATCHES
        0001-fix-cmake-install.patch
        0002-fix-error-C2338.patch
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
