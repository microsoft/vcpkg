vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO davea42/libdwarf-code
    REF "v${VERSION}"
    SHA512 ff856a53aca16c8389e34974d5f852dc46dec5ebd1731d8dc0f675eb981d7024d772ab03285107a1849a2df626da705e7e4a971225fb4b1709d305d956d49989
    HEAD_REF main
    PATCHES
        include-dir.diff # avoid dwarf.h conflict with elfutils
        dependencies.diff
        msvc-runtime.diff
        dwarfdump-conf.diff # no absolute paths
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINSTALL_STATIC_LIBRARIES=${BUILD_STATIC}
    OPTIONS_DEBUG
        -DBUILD_DWARFDUMP=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libdwarf")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES dwarfdump AUTO_CLEAN)

if(BUILD_STATIC)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libdwarf/libdwarf.h" "ifndef LIBDWARF_STATIC" "if 0")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/libdwarf/Findzstd.cmake"
)

file(COPY_FILE "${SOURCE_PATH}/src/lib/libdwarf/COPYING" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libdwarf COPYING")
file(COPY_FILE "${SOURCE_PATH}/src/bin/dwarfdump/COPYING" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dwarfdump COPYING")
file(COPY_FILE "${SOURCE_PATH}/src/bin/dwarfgen/COPYING" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dwarfgen COPYING")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libdwarf COPYING"
    "${SOURCE_PATH}/src/lib/libdwarf/LIBDWARFCOPYRIGHT"
    "${SOURCE_PATH}/src/lib/libdwarf/LGPL.txt"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dwarfdump COPYING"
    "${SOURCE_PATH}/src/bin/dwarfdump/DWARFDUMPCOPYRIGHT"
    "${SOURCE_PATH}/src/bin/dwarfdump/GPL.txt"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dwarfgen COPYING"
)
