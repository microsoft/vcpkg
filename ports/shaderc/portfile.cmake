#Note: glslang and spir tools doesn't export symbol and need to be build as static lib for cmake to work
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/shaderc
    REF 05c766a1f4615ee37d37d09271aaabca30ffd293
    SHA512 329697e8e23d619313440d57ef740a94c49d13533e1b8734fc8ff72fd5092c2addabb306f64cb69160fa5fee373a05ba39a5ee6d92d95e5e2e9c7ec96a51aadc
    HEAD_REF master
    PATCHES 
        disable-update-version.patch
        fix-install.patch
        fix-build-type.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/third_party/glslang)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists_spirv.txt DESTINATION ${SOURCE_PATH}/third_party/spirv-tools)
file(RENAME ${SOURCE_PATH}/third_party/spirv-tools/CMakeLists_spirv.txt ${SOURCE_PATH}/third_party/spirv-tools/CMakeLists.txt)

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
        -Dglslang_SOURCE_DIR=${CURRENT_INSTALLED_DIR}/include
        -Dspirv-tools_SOURCE_DIR=${CURRENT_INSTALLED_DIR}/include 
    OPTIONS_DEBUG
        -DSUFFIX_D=true
    OPTIONS_RELEASE
        -DSUFFIX_D=false
)

vcpkg_install_cmake()

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES glslc AUTO_CLEAN)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
