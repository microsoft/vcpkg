vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/umock-c
    REF e54b586e00f26f36f8f96e389738b8c798ad6fb7
    SHA512 9f108542161dbaab18f08bf48bf98bfdb007de4ece935e05c5e4407cb796588cf515d033fdd2a14bff67f160a733c375b0662aebd57dd110ae25b210ed6ef2f5
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
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/c-build-tools" "${SOURCE_PATH}/deps/c-logging" "${SOURCE_PATH}/deps/macro-utils-c"
    "${SOURCE_PATH}/deps/ctest" "${SOURCE_PATH}/deps/c-testrunnerswitcher")
file(COPY "${C_BUILD_TOOLS_PATH}/" DESTINATION "${SOURCE_PATH}/deps/c-build-tools")
# Ports must not build with warnings as errors.
vcpkg_replace_string("${SOURCE_PATH}/deps/c-build-tools/build_functions/CMakeLists.txt" " -Werror -Wall" " -Wall")
vcpkg_replace_string("${SOURCE_PATH}/deps/c-build-tools/build_functions/CMakeLists.txt" " /W4 /WX " " /W4 ")

# Upstream installs headers only: also install and export the library (target umock_c), as this port always did.
file(APPEND "${SOURCE_PATH}/CMakeLists.txt" [=[

install(TARGETS umock_c EXPORT umock_cExport
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(EXPORT umock_cExport FILE umock_cTargets.cmake DESTINATION share/umock_c)
# umock_lock_factory_pthread.c uses pthread_rwlock_*.
if(UNIX)
    find_package(Threads REQUIRED)
    target_link_libraries(umock_c Threads::Threads)
endif()
]=])

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/find-dependencies.cmake"
        -Drun_unittests=OFF
        -Drun_int_tests=OFF
        -Drun_perf_tests=OFF
        -Drun_reals_check=OFF
        -Drun_traceability=OFF
        -Duse_cppunittest=OFF
        -Duse_installed_dependencies=ON
        -Dbuild_traceability_tool=OFF
        -Dbuild_csharp_projects=OFF
        -Dbuild_sarif_results_checker=OFF
        -Duse_ltcg=OFF
    MAYBE_UNUSED_VARIABLES
        build_csharp_projects
        build_sarif_results_checker
        build_traceability_tool
        use_installed_dependencies
        use_ltcg
        run_traceability
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME umock_c CONFIG_PATH share/umock_c)

# Headers (some are not in the upstream install list).
file(INSTALL "${SOURCE_PATH}/inc/umock_c" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/umock_c/umock_cConfig.cmake" [=[
include(CMakeFindDependencyMacro)
find_dependency(macro_utils_c CONFIG)
find_dependency(c_logging CONFIG)
if(UNIX)
    find_dependency(Threads)
endif()
include("${CMAKE_CURRENT_LIST_DIR}/umock_cTargets.cmake")
get_filename_component(_umock_c_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(UMOCK_C_INCLUDES "${_umock_c_prefix}/include" CACHE INTERNAL "")
set(UMOCK_C_INC_FOLDER "${_umock_c_prefix}/include" CACHE INTERNAL "")
]=])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
