vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aui-framework/aui
    REF "v${VERSION}"
    SHA512 decac6cebb6003791896e8d7a9fd7334351aa30205eac787cdbb51d1da657cda140178e0b8f5d236b42a4c1f37633141fb869784e5fc5c9718b5396e077afe7d
    HEAD_REF master
    PATCHES
        debundle.patch
        disable-tests.patch
        disable-auib.patch
        fix-fmt12.patch
        fix-glm.patch
        fix-macos.patch
        fix-arm64.patch
        fix-public-headers.patch
    )

file(REMOVE_RECURSE "${SOURCE_PATH}/aui.audio/3rdparty" "${SOURCE_PATH}/aui.core/3rdparty" "${SOURCE_PATH}/aui.image/3rdparty" "${SOURCE_PATH}/aui.sqlite/3rdparty")
file(REMOVE "${SOURCE_PATH}/platform/android/project/gradle/wrapper/gradle-wrapper.jar")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/aui-config.cmake.in" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_find_acquire_program(PKGCONFIG)

set(_aui_cmake_options "")
if(VCPKG_CROSSCOMPILING)
    # aui.views compiles assets and shaders at build time with aui.toolbox, which
    # must run on the host. When cross-compiling the in-tree aui.toolbox target is
    # not built (and would target the wrong architecture anyway), so use the
    # host-built tool from the aui-toolbox port. This also keeps AUI Boot from
    # being invoked to fetch a host toolchain.
    find_program(AUI_TOOLBOX_EXE NAMES aui.toolbox
        HINTS "${CURRENT_HOST_INSTALLED_DIR}/tools/aui-toolbox"
        NO_DEFAULT_PATH
    )
    if(NOT AUI_TOOLBOX_EXE)
        message(FATAL_ERROR
            "aui needs the host tool aui.toolbox when cross-compiling; "
            "the aui-toolbox host dependency did not install it")
    endif()
    list(APPEND _aui_cmake_options "-DAUI_TOOLBOX_EXE=${AUI_TOOLBOX_EXE}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${_aui_cmake_options}
        -DAUI_INSTALL_RUNTIME_DEPENDENCIES=OFF
        -DAUIB_NO_PRECOMPILED=TRUE
        -DAUIB_DISABLE=ON
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_INSTALLED_DIR}/bin" "${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/AUI/api.h"
        "#pragma once"
        "#pragma once\n\n#ifndef AUI_STATIC\n#define AUI_STATIC\n#endif"
    )
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/aui.toolbox${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(TOOL_NAMES aui.toolbox AUTO_CLEAN)
endif()

# Remove empty folders
function(_aui_prune_empty_dirs _root)
    file(GLOB _aui_children "${_root}/*")
    foreach(_aui_child IN LISTS _aui_children)
        if(IS_DIRECTORY "${_aui_child}")
            _aui_prune_empty_dirs("${_aui_child}")
            file(GLOB _aui_grandchildren "${_aui_child}/*")
            if(NOT _aui_grandchildren)
                file(REMOVE_RECURSE "${_aui_child}")
            endif()
        endif()
    endforeach()
endfunction()
_aui_prune_empty_dirs("${CURRENT_PACKAGES_DIR}")

if(EXISTS "${CURRENT_PACKAGES_DIR}/aui-config.cmake")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/aui")
    file(RENAME "${CURRENT_PACKAGES_DIR}/aui-config.cmake" "${CURRENT_PACKAGES_DIR}/share/aui/aui-config.cmake")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/aui-config.cmake")

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/aui")
    file(RENAME "${CURRENT_PACKAGES_DIR}/cmake" "${CURRENT_PACKAGES_DIR}/share/aui/cmake")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/cmake")
if(EXISTS "${CURRENT_PACKAGES_DIR}/platform")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/aui")
    file(RENAME "${CURRENT_PACKAGES_DIR}/platform" "${CURRENT_PACKAGES_DIR}/share/aui/platform")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/platform")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
