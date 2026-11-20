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

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

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
        -DJPH_USE_CPU_COMPUTE=ON
        -DENABLE_OBJECT_STREAM=ON
        -DFLOATING_POINT_EXCEPTIONS_ENABLED=ON
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        -DGENERATE_DEBUG_SYMBOLS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(PACKAGE_NAME Jolt CONFIG_PATH "lib/cmake/Jolt")

set(direct_definitions JPH_USE_CPU_COMPUTE JPH_OBJECT_STREAM)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND direct_definitions JPH_SHARED_LIBRARY)
endif()
# Match the library compiler check in https://github.com/jrouwe/JoltPhysics/blob/cf16769bb0ede9c45d57d06068ff0689e9702f5c/Jolt/Jolt.cmake#L848-L851
if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    list(APPEND direct_definitions JPH_FLOATING_POINT_EXCEPTIONS_ENABLED)
endif()
if("debugrenderer" IN_LIST FEATURES)
    list(APPEND direct_definitions JPH_DEBUG_RENDERER)
endif()
if("profiler" IN_LIST FEATURES)
    list(APPEND direct_definitions JPH_PROFILE_ENABLED)
endif()

set(core_preamble "#pragma once\n")
foreach(definition IN LISTS direct_definitions)
    string(APPEND core_preamble "\n#ifndef ${definition}\n#define ${definition}\n#endif")
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Jolt/Core/Core.h" "#pragma once" "${core_preamble}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
