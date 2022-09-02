vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BYVoid/OpenCC
    REF ver.1.1.4
    SHA512 ab8e7e6a0cc71106cf09eb32899fa8620b946a406f042d75a2444096e0b383cb1993d6c2d12cd7862e71854da4cd5893442bce51df84c32ed09fdfb4a2846f46
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
        -DENABLE_GTEST=OFF
        -DUSE_SYSTEM_RAPIDJSON=ON
        -DUSE_SYSTEM_TCLAP=ON
        -DUSE_SYSTEM_DARTS=ON
)

vcpkg_cmake_install(
    DISABLE_PARALLEL
)

vcpkg_copy_pdbs()

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
