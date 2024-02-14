vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO davea42/libdwarf-code
    REF "v${VERSION}"
    SHA512 8e1addaf2b970db792c4488fa416b712c7b48dfe501bbfd5c40a7eaf71f07377abaa70f682982d11de9cf9573d8fd8dc5fd16c020eb9b68b5be558139a0799a1
    HEAD_REF main
    PATCHES
        include-dir.diff
        dependencies.diff
        msvc-runtime.diff
        off_t.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_NON_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_NON_SHARED=${BUILD_NON_SHARED}
        -DBUILD_SHARED=${BUILD_SHARED}
    OPTIONS_DEBUG
        -DBUILD_DWARFDUMP=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libdwarf")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES dwarfdump AUTO_CLEAN)

if(BUILD_SHARED)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libdwarf/libdwarf.h" "ifndef LIBDWARF_STATIC" "if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
