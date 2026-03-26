vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BYVoid/OpenCC
    REF "ver.${VERSION}"
    SHA512 63af2486d7bb2e058243e7edb4793b198472edf052f0909e6ff5819770cfbe1d3d01a4c45916f8e9350537e4d1648d494d7d976e969764c1b51816b492fff0b7
    HEAD_REF master
    PATCHES 
        fix-dependencies.patch
        # marisa-trie/0.3.0 requires C++17, so we need to enable it
        enable-cpp17.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DOCUMENTATION=OFF
        -DENABLE_GTEST=OFF
        -DUSE_SYSTEM_RAPIDJSON=ON
        -DUSE_SYSTEM_TCLAP=ON
        -DUSE_SYSTEM_DARTS=ON
        -DUSE_SYSTEM_MARISA=ON
        -DPKG_CONFIG_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf
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
