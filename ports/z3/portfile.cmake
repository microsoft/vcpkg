vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Z3Prover/z3
  REF z3-${VERSION}
  SHA512 ef752530cec0c08dbc53671c9fd04b6ed4d190905598d3d7dc1cb21dfde97fd0d69962c478ccc60e823718e2c57d9b3ee670f48fd09215597fa44d04b60fb21c
  HEAD_REF master
  PATCHES
      fix-install-path.patch
      remove-flag-overrides.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(BUILD_STATIC "-DZ3_BUILD_LIBZ3_SHARED=OFF")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    ${BUILD_STATIC}
    -DZ3_BUILD_TEST_EXECUTABLES=OFF
    -DZ3_ENABLE_EXAMPLE_TARGETS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/z3)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
