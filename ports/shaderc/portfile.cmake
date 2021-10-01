#Note: glslang and spir tools doesn't export symbol and need to be build as static lib for cmake to work
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/shaderc
    REF adca18dcadd460eb517fe44f6cd2460fa0650ebe
    SHA512 3a27d4c51be9e9396b9a854cb96d88e78ff2ca6dcb8400bd3288f6984d25876af0eae649aa1c72ad613edbbcfa4324a12809f13ceb7a0134eef41cb1a698dfdf
    HEAD_REF master
    PATCHES 
        disable-update-version.patch
        fix-build-type.patch
        fix-install-shaderc_util.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/build-version.inc DESTINATION ${SOURCE_PATH}/glslc/src)

set(OPTIONS)
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS -DSHADERC_ENABLE_SHARED_CRT=ON)
endif()

# shaderc uses python to manipulate copyright information
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${OPTIONS}
        -DSHADERC_SKIP_TESTS=true 
        -DSHADERC_GLSLANG_DIR=${CMAKE_CURRENT_LIST_DIR}/glslang
        -DSHADERC_SPIRV_TOOLS_DIR=${CMAKE_CURRENT_LIST_DIR}/spirv-tools
        -DSHADERC_ENABLE_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES glslc AUTO_CLEAN)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
