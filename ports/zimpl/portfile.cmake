vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO scipopt/zimpl
    REF "v${VERSION}"
    SHA512 654235540deb61050cc04f9b0e0554bb7b505bb976e2aa66347b7b134b1b6c095475f5edb26eec8390256f321be9a484ef0906de9ff498ba99b3ae52303cdf9c
    HEAD_REF master
    PATCHES
        libm.diff
        msvc.diff
)

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBREW=false
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=1
    MAYBE_UNUSED_VARIABLES
        BREW
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zimpl)
vcpkg_copy_tools(TOOL_NAMES zimpl AUTO_CLEAN)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zimpl/zimpl-config.cmake" "../../../include" "../../include")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/zimpl/mmlparse2.h" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/zimpl/" "")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
