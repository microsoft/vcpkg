vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphviz/graphviz
    REF 2.49.1
    SHA512 ac14303f67d0840b260c5f2f99c53049a1e444a963d31387ae7a44ffc24757bd44f1c40ddd3fdb6a8d0e0bb1dde0e15d320f613729fb631efd4f078fcb3a4f62
    HEAD_REF main
    PATCHES
        0001-Fix-build.patch
)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk)
vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(GIT)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"

    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBISON_EXECUTABLE=${BISON}
        -DFLEX_EXECUTABLE=${FLEX}
        -DGIT_EXECUTABLE=${GIT}
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
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
