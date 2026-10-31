vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/c-logging
    REF 504e7d4765adc718957cb32cf7699d9e9272c727
    SHA512 5167e68830f5711f1d05874c4d10b582f5472438613a6ef4865345a47948388c31d95f11ed04502072eadefc75e7ea5cf1459bbdf1e460854dcb64d905834231
    HEAD_REF master
)

# CMake helper functions the build uses; pinned to the deps/c-build-tools submodule.
vcpkg_from_github(
    OUT_SOURCE_PATH C_BUILD_TOOLS_PATH
    REPO Azure/c-build-tools
    REF b26bcf4a6a8eda025b1dce0a6bbfe02e2f7bb4e5
    SHA512 e3ab0bfe0d3a4ab818380111b211985f9c20ccbe012032e4638fc093ab8f19f585b679279c0ef78c81e6bca8fe0ffd821dd602ee72a6096a47e0fc9f814eb17d
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/c-build-tools" "${SOURCE_PATH}/deps/macro-utils-c")
file(COPY "${C_BUILD_TOOLS_PATH}/" DESTINATION "${SOURCE_PATH}/deps/c-build-tools")
# Ports must not build with warnings as errors.
vcpkg_replace_string("${SOURCE_PATH}/deps/c-build-tools/build_functions/CMakeLists.txt" " -Werror -Wall" " -Wall")
vcpkg_replace_string("${SOURCE_PATH}/deps/c-build-tools/build_functions/CMakeLists.txt" " /W4 /WX " " /W4 ")

# get_thread_stack.c supports x64/ARM64 only (#error on x86); same no-op stub as azure-iot-sdk-c's compat_stubs.
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    file(WRITE "${SOURCE_PATH}/v2/src/get_thread_stack.c" [=[
#include <stdio.h>
#include "windows.h"
#include "c_logging/get_thread_stack.h"

int get_thread_stack_init(void)
{
    return 0;
}

void get_thread_stack(DWORD threadId, char* destination, size_t destinationSize)
{
    (void)threadId;
    if (destination != NULL && destinationSize > 0)
    {
        (void)snprintf(destination, destinationSize, "stack capture not supported on x86");
    }
}

void get_thread_stack_refresh_module_list(void)
{
}

void get_thread_stack_deinit(void)
{
}
]=])
endif()

# Upstream installs headers only (no CMake package): install and export both libraries as vcpkg package
# unofficial-c-logging (targets unofficial::c-logging::c_logging_v2, unofficial::c-logging::c_logging_v2_core).
# Headers go to include/c_logging so the include root alone resolves "c_logging/<header>.h".
file(APPEND "${SOURCE_PATH}/v2/CMakeLists.txt" [=[

install(TARGETS c_logging_v2 c_logging_v2_core EXPORT unofficial-c-logging-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/c_logging
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(EXPORT unofficial-c-logging-targets NAMESPACE unofficial::c-logging::
    FILE unofficial-c-logging-targets.cmake DESTINATION share/unofficial-c-logging)
]=])

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/find-dependencies.cmake"
        -Drun_unittests=OFF
        -Drun_int_tests=OFF
        -Drun_e2e_tests=OFF
        -Drun_traceability=OFF
        -Drun_reals_check=OFF
        -Duse_cppunittest=OFF
        -Dbuild_traceability_tool=OFF
        -Dbuild_csharp_projects=OFF
        -Dbuild_sarif_results_checker=OFF
        -Duse_ltcg=OFF
    MAYBE_UNUSED_VARIABLES
        build_csharp_projects
        build_sarif_results_checker
        build_traceability_tool
        use_ltcg
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-c-logging CONFIG_PATH share/unofficial-c-logging)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-c-logging/unofficial-c-logging-config.cmake" [=[
include(CMakeFindDependencyMacro)
find_dependency(macro_utils_c CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-c-logging-targets.cmake")
]=])

# The upstream install rule also copies the headers to include/c_logging/v2/c_logging.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/c_logging/v2"
    "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
