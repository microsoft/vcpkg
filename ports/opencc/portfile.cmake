vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BYVoid/OpenCC
    REF "ver.${VERSION}"
    SHA512 8638e5ca665c3451d716e5a65ddd998c5312975d0f69e5d0d72910104c9bc44a4989562468605db66f5f92e5ca1bf21815266dfe21a0d130bf5f02ebcbb7cba7
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_OPENCC_JIEBA_PLUGIN=OFF
        -DBUILD_PYTHON=OFF
        -DENABLE_BENCHMARK=OFF
        -DENABLE_GTEST=OFF
        -DUSE_SYSTEM_RAPIDJSON=ON
        -DUSE_SYSTEM_TCLAP=ON
        -DUSE_SYSTEM_DARTS=ON
        -DUSE_SYSTEM_MARISA=ON
)

vcpkg_cmake_install(
    DISABLE_PARALLEL
)

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/opencc)

vcpkg_fixup_pkgconfig()

set(tool_names "opencc" "opencc_dict" "opencc_phrase_extract")
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ${tool_names} AUTO_CLEAN)
endif()

foreach(opencc_tool IN LISTS tool_names)
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        "${CURRENT_PACKAGES_DIR}/debug/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    )
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
