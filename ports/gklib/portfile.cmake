vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KarypisLab/GKlib
    REF b1cb3bd7f6bf4da641af901c8d455c0f858c816f
    SHA512 e906c7af8b40ce1c4c4ea43cbfca3e3970e5595686333ac9ac80c6cbc558feb0e833f530f034161927030edac5272234c6ac9cad5287cb6edab0c0671ba3644c
    PATCHES
        build-fixes.patch
        fix-mingw.patch
)

# Delete files that are workarounds for very old copies of msvc.
file(REMOVE "${SOURCE_PATH}/ms_inttypes.h" "${SOURCE_PATH}/ms_stdint.h")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" [=[
gklib provides CMake targets:
    find_package(GKlib CONFIG REQUIRED)
    target_link_libraries(main PRIVATE GKlib)
]=])
