vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# EASTL uses leading zeros in tags (e.g., 3.27.01), but vcpkg drops them in versions
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1.\\2.0\\3" EASTL_REF "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF "${EASTL_REF}"
    SHA512 08ac403fceb032cc8622e3f15eef0b00246b8abb2daceb8fabd66d23408c738e82126a4b5187201ec7f6606df46cca1fcda1ec646cfe18ec8e9e081a057101e3
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
