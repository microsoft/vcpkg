vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/ChakraCore
    REF fd6908097f758ef65bd83680cf413313ad36c98d
    SHA512 c35a2e3680d3ff5c7d715752570b5f12cf9da716ef28377694e9aa079553b5c0276c51a66b342956d217e9842edd12c25af4a001fae34175a2114134ee4428ee
    HEAD_REF master
    PATCHES
        add-missing-reference.patch # https://github.com/chakra-core/ChakraCore/pull/6862
)

if(WIN32)
    find_path(COR_H_PATH cor.h)
    if(COR_H_PATH MATCHES "NOTFOUND")
        message(FATAL_ERROR "Could not find <cor.h>. Ensure the NETFXSDK is installed.")
    endif()
    get_filename_component(NETFXSDK_PATH "${COR_H_PATH}/../.." ABSOLUTE)
endif()

set(BUILDTREE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
file(REMOVE_RECURSE ${BUILDTREE_PATH})
file(COPY ${SOURCE_PATH}/ DESTINATION ${BUILDTREE_PATH})

if(WIN32)
    set(CHAKRA_RUNTIME_LIB "static_library") # ChakraCore only supports static CRT linkage
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(PLATFORM_ARG PLATFORM x86) # it's x86, not Win32 in sln file
    endif()
    vcpkg_install_msbuild(
        SOURCE_PATH "${BUILDTREE_PATH}"
        PROJECT_SUBPATH "Build/Chakra.Core.sln"
        OPTIONS
            "/p:DotNetSdkRoot=${NETFXSDK_PATH}/"
            "/p:CustomBeforeMicrosoftCommonTargets=${CMAKE_CURRENT_LIST_DIR}/no-warning-as-error.props"
            "/p:RuntimeLib=${CHAKRA_RUNTIME_LIB}"
        ${PLATFORM_ARG}
    )
    file(GLOB_RECURSE LIB_FILES "${CURRENT_PACKAGES_DIR}/lib/*.lib")
    file(GLOB_RECURSE DEBUG_LIB_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib")
    foreach(file ${LIB_FILES} ${DEBUG_LIB_FILES})
        if(NOT file MATCHES "ChakraCore.lib")
            file(REMOVE ${file})
        endif()
    endforeach()
else()
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(CHAKRACORE_TARGET_ARCH amd64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(CHAKRACORE_TARGET_ARCH x86)
    endif()

    if (VCPKG_TARGET_IS_LINUX)
        message(WARNING "${PORT} requires Clang from the system package manager, this can be installed on Ubuntu systems via sudo apt install clang")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        list(APPEND configs "debug")
        execute_process(
            COMMAND bash "build.sh" "--arch=${CHAKRACORE_TARGET_ARCH}" "--debug" "-j=${VCPKG_CONCURRENCY}"
            WORKING_DIRECTORY "${BUILDTREE_PATH}"

            OUTPUT_VARIABLE CHAKRA_BUILD_SH_OUT
            ERROR_VARIABLE CHAKRA_BUILD_SH_ERR
            RESULT_VARIABLE CHAKRA_BUILD_SH_RES
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
        )
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        list(APPEND configs "release")
        execute_process(
            COMMAND bash "build.sh" "--arch=${CHAKRACORE_TARGET_ARCH}" "-j=${VCPKG_CONCURRENCY}"
            WORKING_DIRECTORY "${BUILDTREE_PATH}"
            OUTPUT_VARIABLE CHAKRA_BUILD_SH_OUT
            ERROR_VARIABLE CHAKRA_BUILD_SH_ERR
            RESULT_VARIABLE CHAKRA_BUILD_SH_RES
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
        )
    endif()
endif()

file(INSTALL
    "${BUILDTREE_PATH}/lib/Jsrt/ChakraCore.h"
    "${BUILDTREE_PATH}/lib/Jsrt/ChakraCommon.h"
    "${BUILDTREE_PATH}/lib/Jsrt/ChakraDebug.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)
if(WIN32)
    file(INSTALL
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraCommonWindows.h"
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraCoreWindows.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    )
    # Do not install dll/exe/lib files here because they are handled by vcpkg_install_msbuild
else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(out_file libChakraCore.so)
    else()
        set(out_file lib/libChakraCoreStatic.a)
    endif()

    set(destination_dir_debug "${CURRENT_PACKAGES_DIR}/debug/lib")
    set(destination_dir_release "${CURRENT_PACKAGES_DIR}/lib")
    set(out_dir_debug "${BUILDTREE_PATH}/out/Debug")
    set(out_dir_release "${BUILDTREE_PATH}/out/Release")
    foreach(config ${configs})
        file(INSTALL
            ${out_dir_${config}}/${out_file}
            DESTINATION ${destination_dir_${config}}
        )
    endforeach()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(INSTALL
            "${out_dir_release}/ch"
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/chakracore"
        )
        vcpkg_copy_tools(TOOL_NAMES ch
            SEARCH_DIR "${out_dir_release}"
        )
    endif()
endif()

vcpkg_copy_pdbs()

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/chakracore"
    RENAME copyright
)
