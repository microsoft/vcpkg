vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/glslang
  REF c594de23cdd790d64ad5f9c8b059baae0ee2941d
  SHA512 4b9e300152dc2ec3b14657b3a745d5b26b5da49e5ff3da0d75680f84126237ec6af0f7cee5aaa74b2d4a123a386522cd7342b5f25e4c01f114da3d5d92057128
  HEAD_REF master
  PATCHES
    CMakeLists-targets.patch
    CMakeLists-os.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path("${PYTHON_PATH}")

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=d
    -DSKIP_GLSLANG_INSTALL=OFF
    -DENABLE_GLSLANG_BINARIES=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/glslang)

vcpkg_copy_pdbs()

file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/glslang)
