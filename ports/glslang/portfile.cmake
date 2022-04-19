vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/glslang
  REF 11.8.0
  SHA512 b60d328fab6d5319e49fbf8aeb86c31a7c8dfb4bc75d39c081cbb72f90750fd98f2a4f3ab091614187ad9e0d2e27471f9dab7ca5547cabb856d17bff694f8c98
  HEAD_REF master
  PATCHES
    ignore-crt.patch
    always-install-resource-limits.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path("${PYTHON_PATH}")

if(VCPKG_TARGET_IS_IOS)
  # this case will report error since all executable will require BUNDLE DESTINATION
  set(BUILD_BINARIES OFF)
else()
  set(BUILD_BINARIES ON)  
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DSKIP_GLSLANG_INSTALL=OFF
    -DBUILD_EXTERNAL=OFF
    -DENABLE_GLSLANG_BINARIES=${BUILD_BINARIES}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

vcpkg_copy_pdbs()

if(NOT BUILD_BINARIES)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
else()
  vcpkg_copy_tools(TOOL_NAMES glslangValidator spirv-remap AUTO_CLEAN)
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/bin")

if(EXISTS "${CURRENT_PACKAGES_DIR}/share/glslang/glslang-config.cmake" OR EXISTS "${CURRENT_PACKAGES_DIR}/share/glslang/glslangConfig.cmake")
  message(FATAL_ERROR "glslang has been updated to provide a -config file -- please remove the vcpkg provided version from the portfile")
endif()

file(COPY
  "${CMAKE_CURRENT_LIST_DIR}/glslang-config.cmake"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
