vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  ispc/ispc
    REF 222aa0a8628965f2ce5c53e922a7334be75f8c9b
    SHA512 63ee00e23187b9fa6dda95a0c3e1e7404564e49ea4915b400baaa204d6f6a4b80af94d486c416651893088ff77201246c45dea3e93e7920d5741b1ee41a7a2d9
    HEAD_REF master
    PATCHES fix-build.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")
vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path("${FLEX_DIR}")
vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_DIR "${GIT}" DIRECTORY)
vcpkg_add_to_path("${GIT_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path("${BISON_DIR}")
vcpkg_acquire_msys(MSYS_ROOT PACKAGES m4)
vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ISPCRT_BUILD_STATIC)

vcpkg_replace_string("${SOURCE_PATH}/ispcrt/CMakeLists.txt" [[build_ispcrt(SHARED ${PROJECT_NAME})]] 
                                                            "if(BUILD_SHARED_LIBS)\nbuild_ispcrt(SHARED \${PROJECT_NAME})\nendif()"
                    )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DISPC_INCLUDE_TESTS=OFF
      -DISPC_INCLUDE_EXAMPLES=OFF
      -DISPCRT_BUILD_TASK_MODEL=Threads
      -DISPCRT_BUILD_STATIC=${ISPCRT_BUILD_STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ispcrt-${VERSION} PACKAGE_NAME ispcrt)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ispcrt/ispcrtConfig.cmake" "/../include" "/include")

vcpkg_copy_tools(TOOL_NAMES ispc check_isa AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
