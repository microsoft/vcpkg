set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # for plugins

vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphviz/graphviz
    REF "${VERSION}"
    SHA512 5872db8aefb9bebf6fea91dbe96759c42fa82dbe811238c7d6de8db5a0c6af77749083af60fc21f8e42c4fc159a2cbfefcc304967edda3d2832ef396c457530a
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
        no-absolute-paths.patch
        select-plugins.patch
        static-linkage.patch
)

if(VCPKG_TARGET_IS_OSX)
    message("${PORT} currently requires the following libraries from the system package manager:\n    libtool\n\nThey can be installed with brew install libtool")
elseif(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following libraries from the system package manager:\n    libtool\n\nThey can be installed with apt-get install libtool")
endif()

vcpkg_list(SET OPTIONS)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_download_distfile(
        LTDL_H_PATH
        URLS "https://gitlab.com/graphviz/graphviz-windows-dependencies/-/raw/141d3a21be904fa8dc2ae3ed01d36684db07a35d/${VCPKG_TARGET_ARCHITECTURE}/include/ltdl.h"
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
    DISABLE_PARALLEL_CONFIGURE
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
        -Dwith_smyrna=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_ANN=ON
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
    TOOL_NAMES acyclic bcomps ccomps circo diffimg dijkstra dot edgepaint fdp gc gml2gv graphml2gv gv2gml gvcolor gvgen gvmap gvpack gvpr gxl2gv mm2gv neato nop osage patchwork sccmap sfdp tred twopi unflatten
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
