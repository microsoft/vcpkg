set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Test for empty string
set(macho_dir "${CURRENT_PACKAGES_DIR}/lib")
set(test_rpath "")
set(expected "@loader_path")

z_vcpkg_calculate_corrected_macho_rpath(
  MACHO_FILE_DIR "${macho_dir}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# Test for empty string in the tools directory
set(macho_dir "${CURRENT_PACKAGES_DIR}/tools/hdf5")
set(test_rpath "")
set(expected "@loader_path/../../lib")

z_vcpkg_calculate_corrected_macho_rpath(
  MACHO_FILE_DIR "${macho_dir}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# macho dir in subdir
set(macho_dir "${CURRENT_PACKAGES_DIR}/lib/somesubdir")
set(test_rpath "")
set(expected "@loader_path/..")

z_vcpkg_calculate_corrected_macho_rpath(
  MACHO_FILE_DIR "${macho_dir}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath for '${macho_dir}' does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# Getting more complex
set(macho_dir "${CURRENT_PACKAGES_DIR}/plugins/notlib/extrasubdir")
set(test_rpath "")
set(expected "@loader_path/../../../lib")

z_vcpkg_calculate_corrected_macho_rpath(
  MACHO_FILE_DIR "${macho_dir}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()
