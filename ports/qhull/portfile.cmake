vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qhull/qhull
    REF v8.0.0 # Qhull 2020.1
    SHA512 b6ac17193b7c8a4ffb5f5a64cc057d1d5123f155f1c4fcd290fe1768356fef5c58d511707bba8c4814ca754bc6cdf5c370af23953d00c24a5ec28b8a1e489d31
    HEAD_REF master
    PATCHES
        mac-fix.patch
        target-fix.patch
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
