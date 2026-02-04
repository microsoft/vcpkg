vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphviz/graphviz
    REF "${VERSION}"
    SHA512 3f58d94750b80b527fdbdf3e745af514a80d5d1a6479768bae7ccfb94fe458dcca939a18c53de2ddc15bd464028efa473c777b5265ac787231526849a2232d56
    HEAD_REF main
    PATCHES
        build.diff
        dependencies.diff
        install.diff
        no-absolute-paths.patch
        skip-configure-plugins.diff
        version.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        tools   GRAPHVIZ_CLI
)

foreach(lang IN ITEMS D GO GUILE JAVA JAVASCRIPT LUA PERL PHP PYTHON R RUBY SHARP TCL)
    list(APPEND OPTIONS -DENABLE_${lang}=OFF)
endforeach()

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        "-DVERSION=${VERSION}"
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DPython3_EXECUTABLE=${PYTHON3}"
        -Dinstall_win_dependency_dlls=OFF
        -Duse_win_pre_inst_libs=OFF
        -DENABLE_LTDL=ON
        -DENABLE_SWIG=OFF
        -DWITH_EXPAT=ON
        -DWITH_GDK=OFF
        -DWITH_GHOSTSCRIPT=OFF
        -DWITH_GTK=OFF
        -DWITH_GVEDIT=OFF
        -DWITH_POPPLER=OFF
        -DWITH_RSVG=ON
        -DWITH_SMYRNA=OFF
        -DWITH_WEBP=ON
        -DWITH_X=OFF
        -DWITH_ZLIB=ON
        -DVCPKG_LOCK_FIND_PACKAGE_AA=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_ANN=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_CAIRO=ON
        -DVCPKG_LOCK_FIND_PACKAGE_DevIL=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_EXPAT=ON
        -DVCPKG_LOCK_FIND_PACKAGE_Freetype=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_GD=ON
        -DVCPKG_LOCK_FIND_PACKAGE_GTS=ON
        -DVCPKG_LOCK_FIND_PACKAGE_PANGOCAIRO=ON
        ${OPTIONS}
    OPTIONS_DEBUG
        -DGRAPHVIZ_CLI=OFF
    MAYBE_UNUSED_VARIABLES
        install_win_dependency_dlls
)
vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/graphviz)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/graphvizConfig.cmake" cmake-config)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/graphvizConfig.cmake"
        "include(CMakeFindDependencyMacro)\nfind_dependency(getopt CONFIG)\n${cmake-config}"
    )
endif()

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

if("tools" IN_LIST FEATURES)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    foreach(script_or_link IN ITEMS "dot2gxl${VCPKG_TARGET_EXECUTABLE_SUFFIX}" gvmap.sh dot_sandbox)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${script_or_link}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script_or_link}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script_or_link}")
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
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_copy_tools(TOOL_NAMES dot_builtins AUTO_CLEAN)
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
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
