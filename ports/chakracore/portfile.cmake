vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/ChakraCore
    REF 385409ee4b634b860e090606a28acbc99f4d2567
    SHA512 ef47db988c4ddd77fa87f4c5e1ac91d9f6b31b35aa6934d8b2863ee1274776d90a2b85dbad51eef069c96777d3cd7729349b89f23eda8c61b4cb637150bead71
    HEAD_REF master
    PATCHES
        fix-debug-linux-build.patch
)

if(WIN32)
    find_path(COR_H_PATH cor.h)
    if(COR_H_PATH MATCHES "NOTFOUND")
        message(FATAL_ERROR "Could not find <cor.h>. Ensure the NETFXSDK is installed.")
    endif()
    get_filename_component(NETFXSDK_PATH "${COR_H_PATH}/../.." ABSOLUTE)
endif()

set(BUILDTREE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
if(WIN32)
    set(CHAKRA_RUNTIME_LIB "static_library") # ChakraCore only supports static CRT linkage
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH Build/Chakra.Core.sln
        OPTIONS
            "/p:DotNetSdkRoot=${NETFXSDK_PATH}/"
            "/p:RuntimeLib=${CHAKRA_RUNTIME_LIB}"
        INCLUDES_SUBPATH "lib/Jsrt"
        INCLUDE_INSTALL_DIR "${CURRENT_PACKAGES_DIR}/include"
        LICENSE_SUBPATH "LICENSE.txt"
    )
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
            WORKING_DIRECTORY "${BUILDTREE_PATH}-dbg"

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
            WORKING_DIRECTORY "${BUILDTREE_PATH}-rel"
            OUTPUT_VARIABLE CHAKRA_BUILD_SH_OUT
            ERROR_VARIABLE CHAKRA_BUILD_SH_ERR
            RESULT_VARIABLE CHAKRA_BUILD_SH_RES
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
        )
    endif()
    file(INSTALL
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraCore.h"
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraCommon.h"
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraDebug.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    )
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(out_file libChakraCore.so)
    else()
        set(out_file lib/libChakraCoreStatic.a)
    endif()

    set(destination_dir_debug "${CURRENT_PACKAGES_DIR}/debug/bin")
    set(destination_dir_release "${CURRENT_PACKAGES_DIR}/bin")
    set(out_dir_debug "${BUILDTREE_PATH}-dbg/out/Debug")
    set(out_dir_release "${BUILDTREE_PATH}-rel/out/Release")
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
        vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/chakracore")
    endif()
else()
    file(GLOB PDLIBS "${CURRENT_PACKAGES_DIR}/debug/lib/*")
    file(GLOB PRLIBS "${CURRENT_PACKAGES_DIR}/lib/*")
    list(FILTER PDLIBS EXCLUDE REGEX ".*/ChakraCore.lib$")
    list(FILTER PRLIBS EXCLUDE REGEX ".*/ChakraCore.lib$")
    file(REMOVE ${PDLIBS} ${PRLIBS})
endif()

vcpkg_copy_pdbs()

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/chakracore"
    RENAME copyright
)
