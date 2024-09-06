set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Test for empty string
set(elf_dir "${CURRENT_PACKAGES_DIR}/lib")
set(test_rpath "")
set(expected "$ORIGIN")

z_vcpkg_calculate_corrected_rpath(
  ELF_FILE_DIR "${elf_dir}"
  ORG_RPATH "${test_rpath}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not agree with expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath agrees with expected rpath: '${new_rpath}' ")
endif()

# Test for empty string in the tools directory
set(elf_dir "${CURRENT_PACKAGES_DIR}/tools/hdf5")
set(test_rpath "")
set(expected "$ORIGIN:$ORIGIN/../../lib")

z_vcpkg_calculate_corrected_rpath(
  ELF_FILE_DIR "${elf_dir}"
  ORG_RPATH "${test_rpath}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not agree with expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath agrees with expected rpath: '${new_rpath}' ")
endif()

# Simple replacement and outside path test
set(elf_dir "${CURRENT_PACKAGES_DIR}/lib")
set(test_rpath "${CURRENT_PACKAGES_DIR}/lib:/usr/lib/")
set(expected "$ORIGIN")

z_vcpkg_calculate_corrected_rpath(
  ELF_FILE_DIR "${elf_dir}"
  ORG_RPATH "${test_rpath}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not agree with expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath agrees with expected rpath: '${new_rpath}' ")
endif()

# Simple pkgconfig path and outside path test
set(elf_dir "${CURRENT_PACKAGES_DIR}/lib/")
set(test_rpath "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/../../lib:/usr/lib/")
set(expected "$ORIGIN")

z_vcpkg_calculate_corrected_rpath(
  ELF_FILE_DIR "${elf_dir}"
  ORG_RPATH "${test_rpath}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not agree with expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath agrees with expected rpath: '${new_rpath}' ")
endif()

# elf dir in subdir
set(elf_dir "${CURRENT_PACKAGES_DIR}/lib/somesubdir")
set(test_rpath "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/../../lib:/usr/lib/")
set(expected "$ORIGIN:$ORIGIN/..")

z_vcpkg_calculate_corrected_rpath(
  ELF_FILE_DIR "${elf_dir}"
  ORG_RPATH "${test_rpath}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not agree with expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath agrees with expected rpath: '${new_rpath}' ")
endif()

# Getting more complex
set(elf_dir "${CURRENT_PACKAGES_DIR}/plugins/notlib/extrasubdir")
set(test_rpath "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/../../lib/someotherdir2:${CURRENT_INSTALLED_DIR}/lib/pkgconfig/../../someotherdir1:/usr/lib/")
set(expected "$ORIGIN:$ORIGIN/../../../lib:$ORIGIN/../../../lib/someotherdir2:$ORIGIN/../../../someotherdir1")

z_vcpkg_calculate_corrected_rpath(
  ELF_FILE_DIR "${elf_dir}"
  ORG_RPATH "${test_rpath}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not agree with expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath agrees with expected rpath: '${new_rpath}' ")
endif()


set(X_VCPKG_RPATH_KEEP_SYSTEM_PATHS ON)
# Simple replacement and outside path test
set(elf_dir "${CURRENT_PACKAGES_DIR}/lib")
set(test_rpath "${CURRENT_PACKAGES_DIR}/lib:/usr/lib/")
set(expected "$ORIGIN:/usr/lib")

z_vcpkg_calculate_corrected_rpath(
  ELF_FILE_DIR "${elf_dir}"
  ORG_RPATH "${test_rpath}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not agree with expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath agrees with expected rpath: '${new_rpath}' ")
endif()
