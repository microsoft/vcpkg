vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/shaderc
    REF adca18dcadd460eb517fe44f6cd2460fa0650ebe
    SHA512 3a27d4c51be9e9396b9a854cb96d88e78ff2ca6dcb8400bd3288f6984d25876af0eae649aa1c72ad613edbbcfa4324a12809f13ceb7a0134eef41cb1a698dfdf
    HEAD_REF master
    PATCHES 
        disable-update-version.patch
        fix-build-type.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/build-version.inc DESTINATION ${SOURCE_PATH}/glslc/src)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" SHADERC_SHARED_CRT)

# shaderc uses python to manipulate copyright information
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSHADERC_ENABLE_SHARED_CRT=${SHADERC_SHARED_CRT}
        -DSHADERC_GLSLANG_DIR=${CMAKE_CURRENT_LIST_DIR}/glslang
        -DSHADERC_SPIRV_TOOLS_DIR=${CMAKE_CURRENT_LIST_DIR}/spirv-tools
        -DSHADERC_SKIP_INSTALL=OFF
        -DSHADERC_SKIP_TESTS=ON 
        -DSHADERC_SKIP_EXAMPLES=ON
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES glslc AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
