vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chakra-core/ChakraCore
    REF fd6908097f758ef65bd83680cf413313ad36c98d
    SHA512 c35a2e3680d3ff5c7d715752570b5f12cf9da716ef28377694e9aa079553b5c0276c51a66b342956d217e9842edd12c25af4a001fae34175a2114134ee4428ee
    HEAD_REF master
    PATCHES
        add-missing-reference.patch # https://github.com/chakra-core/ChakraCore/pull/6862
        cmake-install.patch
        icu.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    find_path(COR_H_PATH cor.h)
    if(NOT COR_H_PATH)
        message(FATAL_ERROR "Could not find <cor.h>. Ensure the NETFXSDK is installed.")
    endif()
    get_filename_component(NETFXSDK_PATH "${COR_H_PATH}/../.." ABSOLUTE)

    set(BUILDTREE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    file(REMOVE_RECURSE "${BUILDTREE_PATH}")
    file(COPY "${SOURCE_PATH}/" DESTINATION "${BUILDTREE_PATH}")

    set(CHAKRA_RUNTIME_LIB "")
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(CHAKRA_RUNTIME_LIB "static_library")
    endif()
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
    # Do not install dll/exe/lib files here because they are handled by vcpkg_install_msbuild
    file(INSTALL
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraCore.h"
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraCommon.h"
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraDebug.h"
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraCommonWindows.h"
        "${BUILDTREE_PATH}/lib/Jsrt/ChakraCoreWindows.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    )
    file(GLOB_RECURSE LIB_FILES "${CURRENT_PACKAGES_DIR}/lib/*.lib")
    file(GLOB_RECURSE DEBUG_LIB_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib")
    foreach(file IN LISTS LIB_FILES DEBUG_LIB_FILES)
        if(NOT file MATCHES "ChakraCore.lib")
            file(REMOVE "${file}")
        endif()
    endforeach()
    vcpkg_copy_pdbs()
else()
    if(VCPKG_TARGET_IS_LINUX)
        message(WARNING "${PORT} requires Clang from the system package manager, this can be installed on Ubuntu systems via sudo apt install clang")
    endif()
    # WIP
    set(VCPKG_CLANG_COMPILER "clang" CACHE STRING "clang C compiler")
    set(VCPKG_CLANGXX_COMPILER "clang++" CACHE STRING "clang C++ compiler")
    vcpkg_list(APPEND compiler_options
        "-DCMAKE_C_COMPILER=${VCPKG_CLANG_COMPILER}"
        "-DCMAKE_CXX_COMPILER=${VCPKG_CLANGXX_COMPILER}"
    )

    # Configure CMake as if called from build.sh
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC_LIBRARY)
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED_LIBRARY)
    vcpkg_list(SET build_sh_options
        -DCHAKRACORE_BUILD_SH=ON
        -DSTATIC_LIBRARY_SH=${STATIC_LIBRARY}
        -DSHARED_LIBRARY_SH=${SHARED_LIBRARY}
    )
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        vcpkg_list(APPEND build_sh_options -DCC_TARGETS_AMD64_SH=1)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        vcpkg_list(APPEND build_sh_options -DCC_TARGETS_X86_SH=1)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
        vcpkg_list(APPEND build_sh_options -DCC_TARGETS_ARM_SH=1)
    endif()
    if(VCPKG_TARGET_IS_ANDROID)
        vcpkg_list(APPEND build_sh_options -DCC_TARGET_OS_ANDROID=1)
    endif()

    vcpkg_check_features(OUT_FEATURE_OPTIONS feature_options
        FEATURES
            icu     INTL_ICU_SH
            icu     SYSTEM_ICU_SH
        INVERTED_FEATURES
            icu     NO_ICU_SH
            jit     NO_JIT_SH
            tools   LIBS_ONLY_BUILD_SH
    )

    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DVCPKG_TRACE_FIND_PACKAGE=ON
            ${compiler_options}
            ${build_sh_options}
            ${feature_options}
    )
    vcpkg_install_cmake()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

    if("tools" IN_LIST FEATURES)
        vcpkg_copy_tools(TOOL_NAMES ch AUTOCLEAN)
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
