vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF 3df08fe234f23e732a122809b40eb129ae22733f # 2021.5
    SHA512 078b0aef93fb49a974adc365a4147cd2d12704e59d448fa2e510cd4ac8fa77cc4c83eebc5612684ed36a907449c876e5717eba581c195e1d9a7faf0ae832cb00
    HEAD_REF master
)

# Only dynamic lib?
# Warning from CMake: 
# "You are building oneTBB as a static library. This is highly discouraged and such configuration is not supported. Consider building a dynamic library to avoid unforeseen issues."

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DTBB_TEST:BOOL=OFF"
        "-DTBB_EXAMPLES:BOOL=OFF"
        "-DTBB_STRICT:BOOL=OFF" # Warnings as errors
        "-DTBB_WINDOWS_DRIVER:BOOL=OFF" # Build as Universal Windows Driver (UWD)
        "-DTBB4PY_BUILD:BOOL=OFF"
        "-DTBB_DISABLE_HWLOC_AUTOMATIC_SEARCH:BOOL=OFF" # disable hwloc pkgconfig search
        "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TBB)
vcpkg_fixup_pkgconfig()

set(config_file "${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake")
file(READ "${config_file}" contents)
string(PREPEND contents "pkg_search_module(HWLOC hwloc IMPORTED_TARGET)\n")
string(PREPEND contents "find_dependency(PkgConfig)\n")
string(PREPEND contents "find_dependency(Threads)\n")
string(PREPEND contents "include(CMakeFindDependencyMacro)\n")
file(WRITE "${config_file}" "${contents}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")