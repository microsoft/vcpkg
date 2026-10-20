vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/macro-utils-c
    REF 045636acd64c0edf67c1b07fcfc0901d0ecfbd64
    SHA512 52983a1691570b5e4a0f416f295df2cad7a14416b96c78c665cced6ff7300d3d9ee71288533232d7b4300872dcf7870d4e1f087502325f13535df042e9013a4e
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
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/c-build-tools")
file(COPY "${C_BUILD_TOOLS_PATH}/" DESTINATION "${SOURCE_PATH}/deps/c-build-tools")
# Ports must not build with warnings as errors.
vcpkg_replace_string("${SOURCE_PATH}/deps/c-build-tools/build_functions/CMakeLists.txt" " -Werror -Wall" " -Wall")
vcpkg_replace_string("${SOURCE_PATH}/deps/c-build-tools/build_functions/CMakeLists.txt" " /W4 /WX " " /W4 ")

# The headers need MSVC's conforming preprocessor; export it (and C5105, raised by Windows SDK headers with it) to
# consumers, including c_logging and umock_c, which link macro_utils_c.
file(APPEND "${SOURCE_PATH}/CMakeLists.txt" [=[

target_compile_options(macro_utils_c INTERFACE
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/Zc:preprocessor>
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/wd5105>
    $<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/Zc:preprocessor>
    $<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/wd5105>)
]=])

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Drun_int_tests=OFF
        -Drun_unittests=OFF
        -Drun_traceability=OFF
        -Dbuild_traceability_tool=OFF
        -Dbuild_csharp_projects=OFF
        -Dbuild_sarif_results_checker=OFF
        -Duse_ltcg=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME macro_utils_c CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Forwarding headers for code that still includes the pre-rename "azure_macro_utils/" paths.
foreach(header IN ITEMS macro_utils.h macro_utils_generated.h)
    file(WRITE "${CURRENT_PACKAGES_DIR}/include/azure_macro_utils/${header}" "#include \"macro_utils/${header}\"\n")
endforeach()

# Compatibility package for consumers of the former "azure_macro_utils_c" package and target.
file(WRITE "${CURRENT_PACKAGES_DIR}/share/azure_macro_utils_c/azure_macro_utils_cConfig.cmake" [=[
include(CMakeFindDependencyMacro)
find_dependency(macro_utils_c CONFIG)
if(NOT TARGET azure_macro_utils_c)
    add_library(azure_macro_utils_c INTERFACE IMPORTED)
    set_target_properties(azure_macro_utils_c PROPERTIES INTERFACE_LINK_LIBRARIES macro_utils_c)
endif()
get_filename_component(_azure_macro_utils_c_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(MACRO_UTILS_INC_FOLDER "${_azure_macro_utils_c_prefix}/include" CACHE INTERNAL "")
set(AZURE_MACRO_UTILS_C_INCLUDES "${_azure_macro_utils_c_prefix}/include" CACHE INTERNAL "")
]=])

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
