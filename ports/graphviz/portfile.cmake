vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphviz/graphviz
    REF 2.47.3
    SHA512 76b5c7da516f7a3d1bb58203173ed3c00e096f43641ae7e8b97c0046f340d6b67c6a936e0f576bad4c57cff93ebc50f9fbc6340005cb404eac125214204332c2
    HEAD_REF main
    PATCHES
        0001-Fix-build.patch
)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk)
set(AWK_EXE_PATH "${MSYS_ROOT}/usr/bin")
vcpkg_add_to_path("${AWK_EXE_PATH}")

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(GIT)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(FLEX_DIR "${BISON}" DIRECTORY)
get_filename_component(BISON_DIR "${FLEX}" DIRECTORY)
get_filename_component(GIT_DIR "${GIT}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_add_to_path(PREPEND "${GIT_DIR}")
vcpkg_add_to_path(PREPEND "${BISON_DIR}")


vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DPython3_EXECUTABLE=${PYTHON3}
        -DPKG_CONFIG_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/pkgconf/pkgconf
        -Denable_ltdl=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tools(
    TOOL_NAMES acyclic bcomps ccomps circo dijkstra dot fdp gc gml2gv graphml2gv gv2gml gvcolor gvgen gvpack gvpr gxl2gv mm2gv neato nop osage patchwork sccmap sfdp tred twopi unflatten
    AUTO_CLEAN
)

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/graphviz RENAME copyright)
