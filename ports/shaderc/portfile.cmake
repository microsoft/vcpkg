#Note: glslang and spir tools doesn't export symbol and need to be build as static lib for cmake to work
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/shaderc
    REF "v${VERSION}"
    SHA512 4d4f0d7c37d3224e6fb38b320f1ab52e4feb2e5a1c630973c1f00171d90d8d66bef3e44faf996ec67e1568fafc7f767e147fa130d5919b05aad55a78fca7f101
    HEAD_REF master
    PATCHES 
        disable-update-version.patch
        fix-build-type.patch
        cmake-config-export.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/build-version.inc" DESTINATION "${SOURCE_PATH}/glslc/src")

set(OPTIONS "")
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS -DSHADERC_ENABLE_SHARED_CRT=ON)
endif()

# shaderc uses python to manipulate copyright information
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DSHADERC_ENABLE_EXAMPLES=OFF
        -DSHADERC_SKIP_TESTS=true 
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-shaderc CONFIG_PATH share/unofficial-shaderc)

vcpkg_copy_tools(TOOL_NAMES glslc AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
