vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/glslang
  REF ae2a562936cc8504c9ef2757cceaff163147834f
  SHA512 1c5a91e60c1809c6c26f11649659090a75501b0570f3147e5b27ac65c539b591967f258d14c399d33019317864ede823353ea44e0015bc3f7afc5a787f046cc7
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

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DSKIP_GLSLANG_INSTALL=OFF
    -DBUILD_EXTERNAL=OFF
    -DENABLE_GLSLANG_BINARIES=${BUILD_BINARIES}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/glslang)

vcpkg_copy_pdbs()

if(NOT BUILD_BINARIES)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
else()
  file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/glslang)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/bin)

if(EXISTS ${CURRENT_PACKAGES_DIR}/share/glslang/glslang-config.cmake OR EXISTS ${CURRENT_PACKAGES_DIR}/share/glslang/glslangConfig.cmake)
  message(FATAL_ERROR "glslang has been updated to provide a -config file -- please remove the vcpkg provided version from the portfile")
endif()

file(COPY
  ${CMAKE_CURRENT_LIST_DIR}/copyright
  ${CMAKE_CURRENT_LIST_DIR}/glslang-config.cmake
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

