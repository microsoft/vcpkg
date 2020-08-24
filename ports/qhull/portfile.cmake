vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qhull/qhull
    REF e8bcf2fafd7938205e4e5b8b9b921cb7609ff394
    SHA512 c7028a1d2d4d3b8c2d143610c75073c39ce404154d41e2da6e11484e9bcc517f7e770dbad9572c708d87cbd1a0462c915d1d5bdf95e2f0359e9839681334e7bd
    HEAD_REF master
    PATCHES
        mac-fix.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINCLUDE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/include
        -DMAN_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/doc/qhull
        -DDOC_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/doc/qhull
    OPTIONS_RELEASE
        -DLIB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/lib
    OPTIONS_DEBUG
        -DLIB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/lib
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Qhull)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB_RECURSE HTMFILES ${CURRENT_PACKAGES_DIR}/include/*.htm)
file(REMOVE ${HTMFILES})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)

vcpkg_copy_tools(TOOL_NAMES
    qconvex
    qdelaunay
    qhalf
    qhull
    qvoronoi
    rbox
    AUTO_CLEAN
)

file(INSTALL ${SOURCE_PATH}/README.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
