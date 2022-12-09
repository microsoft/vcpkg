vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/glslang
  REF 11.12.0
  SHA512 fd955f9912551668056dfe52835eef11e5dc0bf0d25b2d961a31f684adbd63bc6380759944c1921cfd63d359a58c7cc3a4a4d5eea69fa1b050f58960e5101271
  HEAD_REF master
  PATCHES
    ignore-crt.patch
    install-to-datadir.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path("${PYTHON_PATH}")

if("tools" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_IOS)
  set(BUILD_BINARIES ON)
else()
  # this case will report error since all executable will require BUNDLE DESTINATION
  set(BUILD_BINARIES OFF)
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

# Install custom usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
