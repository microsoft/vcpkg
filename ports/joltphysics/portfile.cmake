vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jrouwe/JoltPhysics
    REF "v${VERSION}"
    SHA512 bacc3bba8b91f63c5e18c2fb1eb9e56b3d301214cf465c30ceca8995aeb016a24e8fcfc9d3f52f6458e03727707b14438b40127acb348b22b3ebd780623ec5f2
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        debugrenderer       DEBUG_RENDERER_IN_DEBUG_AND_RELEASE
        profiler            PROFILER_IN_DEBUG_AND_RELEASE
        rtti                CPP_RTTI_ENABLED
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Build"
    OPTIONS
        -DTARGET_UNIT_TESTS=OFF
        -DTARGET_HELLO_WORLD=OFF
        -DTARGET_PERFORMANCE_TEST=OFF
        -DTARGET_SAMPLES=OFF
        -DTARGET_VIEWER=OFF
        -DCROSS_PLATFORM_DETERMINISTIC=OFF
        -DINTERPROCEDURAL_OPTIMIZATION=OFF
        -DUSE_STATIC_MSVC_RUNTIME_LIBRARY=${USE_STATIC_CRT}
        -DENABLE_ALL_WARNINGS=OFF
        -DOVERRIDE_CXX_FLAGS=OFF
        -DJPH_USE_DX12=OFF
        -DJPH_USE_VK=OFF
        -DJPH_USE_MTL=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        -DGENERATE_DEBUG_SYMBOLS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(PACKAGE_NAME Jolt CONFIG_PATH "lib/cmake/Jolt")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/Jolt/Core/Core.h"
        "#pragma once"
        [=[#pragma once

#ifndef JPH_SHARED_LIBRARY
#define JPH_SHARED_LIBRARY
#endif
#ifndef JPH_FLOATING_POINT_EXCEPTIONS_ENABLED
#define JPH_FLOATING_POINT_EXCEPTIONS_ENABLED
#endif
#ifndef JPH_USE_CPU_COMPUTE
#define JPH_USE_CPU_COMPUTE
#endif
#ifndef JPH_OBJECT_STREAM
#define JPH_OBJECT_STREAM
#endif]=]
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
