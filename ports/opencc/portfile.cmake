vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BYVoid/OpenCC
    REF fae2a0a911c30764e669a7d8b0591cd8e852934a
    SHA512 e56fbf2fad399edd631e4aaca1d64ebcc3f691dfcc74f3765864e6b60bd138be2fcfcd76b8117a9a8d61b28bcb41d6314f2f8fc069f128fc79d230f6f4c3ae95
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

# Darts is intentionally not a dependency: OpenCC always compiles its vendored
# darts-clone, which carries OpenCC-specific patches (validate() and
# copy_array()) that the darts-clone port does not provide, and upstream
# removed the USE_SYSTEM_DARTS branch (BYVoid/OpenCC#1374).
set(opencc_options
    -DBUILD_DOCUMENTATION=OFF
    -DBUILD_OPENCC_JIEBA_PLUGIN=OFF
    -DBUILD_PYTHON=OFF
    -DENABLE_BENCHMARK=OFF
    -DENABLE_GTEST=OFF
    -DUSE_SYSTEM_RAPIDJSON=ON
    -DUSE_SYSTEM_TCLAP=ON
    -DUSE_SYSTEM_MARISA=ON
)

if(VCPKG_CROSSCOMPILING)
    # Generating the dictionaries runs the just-built tools, which the host
    # cannot execute for another target architecture. The host build of this
    # port (see the host dependency in vcpkg.json) provides matching tools;
    # dictionaries are architecture-independent data, so building them with
    # the host tools yields the same result.
    set(opencc_host_tools "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}")
    list(APPEND opencc_options
        "-DOPENCC_DICT_EXECUTABLE=${opencc_host_tools}/opencc_dict${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-DOPENCC_CLI_EXECUTABLE=${opencc_host_tools}/opencc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${opencc_options}
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

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    # OpenCC compiles its vendored darts-clone, whose BSD-2-Clause notice must
    # be reproduced in binary distributions.
    "${SOURCE_PATH}/deps/darts-clone-0.32h/COPYING.md"
)
