set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # for plugins
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled) # kitty and vt plugin not ready yet?

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphviz/graphviz
    REF "${VERSION}"
    SHA512 6b0cffaf4bde7df260894b1b9d74e8a1d5aec11736511a86d99bc369e3f8db99f7050ae917cf1a066cc7d87695a57ef5b9c19521d211fee48c8a0c41ad0f4aac
    HEAD_REF main
    PATCHES
        disable-pragma-lib.patch
        fix-dependencies.patch
        no-absolute-paths.patch
        select-plugins.patch
        static-linkage.patch
        webp-install.patch
        workaround-insufficiently-ugly-wchar-h.patch # Avoids conflict between #define S and VS2022 17.13's <wchar.h>
)

vcpkg_list(SET OPTIONS)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_download_distfile(
        LTDL_H_PATH
        URLS "https://gitlab.com/graphviz/graphviz-windows-dependencies/-/raw/141d3a21be904fa8dc2ae3ed01d36684db07a35d/x64/include/ltdl.h"
        FILENAME graphviz-ltdl-141d3a21.h
        SHA512 f2d20e849e35060536265f47014c40eb70e57dacd600a9db112fc465fbfa6a66217b44a8c3dc33039c260a27f09d9034b329b03cc28c32a22ec503fcd17b78cd
    )
    file(INSTALL "${LTDL_H_PATH}" DESTINATION "${SOURCE_PATH}/libltdl" RENAME ltdl.h)
    vcpkg_list(APPEND OPTIONS "-DLTDL_INCLUDE_DIR=${SOURCE_PATH}/libltdl")
endif()

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    unset(ENV{MSYSTEM_PREFIX})
endif()

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(GIT)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVERSION=${VERSION}"
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
        "-DGIT=${GIT}"
        "-DPython3_EXECUTABLE=${PYTHON3}"
        "-DPKG_CONFIG_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf"
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -Dinstall_win_dependency_dlls=OFF
        -Duse_win_pre_inst_libs=OFF
        -Dwith_gvedit=OFF
        -Dwith_smyrna=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_ANN=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_DevIL=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_CAIRO=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_EXPAT=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_GD=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_LTDL=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_PANGOCAIRO=ON
        ${OPTIONS}
    MAYBE_UNUSED_VARIABLES
        install_win_dependency_dlls
)
vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB headers "${CURRENT_PACKAGES_DIR}/include/graphviz/*.h")
    foreach(file IN LISTS headers)
        vcpkg_replace_string("${file}" "#ifdef GVDLL" "#if 1" IGNORE_UNCHANGED)
    endforeach()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # static libs built with dllexport must be used with dllexport
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphviz/cdt.h" "#ifdef EXPORT_CDT" "#if 1")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphviz/cgraph.h" "#ifdef EXPORT_CGRAPH" "#if 1")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphviz/gvc.h" "#ifdef GVC_EXPORTS" "#if 1")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphviz/gvplugin_loadimage.h" "#ifdef GVC_EXPORTS" "#if 1")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphviz/pack.h" "#ifdef GVC_EXPORTS" "#if 1")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphviz/pathgeom.h" "#ifdef PATHPLAN_EXPORTS" "#if 1")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphviz/pathplan.h" "#ifdef PATHPLAN_EXPORTS" "#if 1")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphviz/xdot.h" "#ifdef EXPORT_XDOT" "#if 1")
    endif()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
foreach(script_or_link IN ITEMS "dot2gxl${VCPKG_TARGET_EXECUTABLE_SUFFIX}" gvmap.sh)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${script_or_link}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script_or_link}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script_or_link}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script_or_link}")
    endif()
endforeach()
vcpkg_copy_tools(
    TOOL_NAMES
        acyclic
        bcomps
        ccomps
        circo
        cluster
        diffimg
        dijkstra
        dot
        edgepaint
        fdp
        gc
        gml2gv
        graphml2gv
        gv2gml
        gv2gxl
        gvcolor
        gvgen
        gvmap
        gvpack
        gvpr
        gxl2dot
        gxl2gv
        mm2gv
        neato
        nop
        osage
        patchwork
        prune
        sccmap
        sfdp
        tred
        twopi
        unflatten
    AUTO_CLEAN
)

file(GLOB plugin_config "${CURRENT_PACKAGES_DIR}/lib/graphviz/config*" "${CURRENT_PACKAGES_DIR}/bin/config*")
if(NOT plugin_config)
    message(WARNING
        "In order to create the plugin configuration file, "
        "you must run `dot -c` on the target system."
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB plugins "${CURRENT_PACKAGES_DIR}/bin/gvplugin_*")
    file(COPY ${plugins} ${plugin_config} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
else()
    file(COPY "${CURRENT_PACKAGES_DIR}/lib/graphviz" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
