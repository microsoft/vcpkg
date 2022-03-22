vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

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

if(VCPKG_TARGET_IS_OSX)
    message("${PORT} currently requires the following libraries from the system package manager:\n    libtool\n\nThey can be installed with brew install libtool")
elseif(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following libraries from the system package manager:\n    libtool\n\nThey can be installed with apt-get install libtool")
else()
    vcpkg_download_distfile(
        LTDL_H_PATH
        URLS "https://gitlab.com/graphviz/graphviz-windows-dependencies/-/raw/141d3a21be904fa8dc2ae3ed01d36684db07a35d/${VCPKG_TARGET_ARCHITECTURE}/include/ltdl.h"
        FILENAME ltdl.h
        SHA512 f2d20e849e35060536265f47014c40eb70e57dacd600a9db112fc465fbfa6a66217b44a8c3dc33039c260a27f09d9034b329b03cc28c32a22ec503fcd17b78cd
    )
    file(COPY ${LTDL_H_PATH} DESTINATION ${SOURCE_PATH}/lib/common)
    set(EXTRA_CMAKE_OPTION "-DLTDL_INCLUDE_DIR=${SOURCE_PATH}/lib/common")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(EXTRA_CMAKE_OPTION "-DCMAKE_INSTALL_RPATH=${CURRENT_INSTALLED_DIR}/lib")
endif()

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
        -DPKG_CONFIG_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf
        ${EXTRA_CMAKE_OPTION}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tools(
    TOOL_NAMES acyclic bcomps ccomps circo dijkstra dot fdp gc gml2gv graphml2gv gv2gml gvcolor gvgen gvpack gvpr gxl2gv mm2gv neato nop osage patchwork sccmap sfdp tred twopi unflatten
    AUTO_CLEAN
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB PLUGINS "${CURRENT_PACKAGES_DIR}/bin/gvplugin_*")
    file(COPY ${PLUGINS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    vcpkg_execute_required_process(
        COMMAND dot -c
        WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}
        LOGNAME configure-plugins
    )
    file(COPY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/config6" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
