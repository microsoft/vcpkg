# SPDX-License-Identifier: MIT
# © DagIR Contributors. All rights reserved.

# Note: do not include vcpkg_common_functions (removed in newer vcpkg).
n# Fetch source from GitHub. Update REF and SHA512 to the desired release tag before
# submitting the port upstream into vcpkg.
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Alan-Jowett/dagir
  REF v0.0.1
  SHA512 F46563BA13C13A3DC5A21F191B834AA5669D52C642503729036F6E192AEB8C3F47CB628DC5C5FF23CE372F767BA25A7E0FFDACEE7E85DF72A5114AE242EEA1CF
)

# Configure and install. DagIR is header-only so we disable tests and samples
# to keep the build minimal inside vcpkg.
vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DDAGIR_BUILD_TESTS=OFF
    -DDAGIR_EXAMPLES=OFF
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_INCLUDEDIR=include
)

vcpkg_install_cmake()

# Ensure any CMake config files installed under lib/cmake are relocated to
# the vcpkg-preferred location `share/<port>`. Some upstream projects
# install their `*Config.cmake` and `*Targets.cmake` into `lib/cmake/...`.
# Move those into `${CURRENT_PACKAGES_DIR}/share/dagir` so `vcpkg_fixup_cmake_targets`
# and other helpers can find and process them correctly.
set(_share_cmake_dir "${CURRENT_PACKAGES_DIR}/share/dagir")
file(MAKE_DIRECTORY "${_share_cmake_dir}")

# If upstream placed CMake package files under lib/cmake/DagIR, copy them
# into the `share/dagir/cmake` folder and remove the old lib/cmake tree.
set(_upstream_lib_cmake "${CURRENT_PACKAGES_DIR}/lib/cmake/DagIR")
if(EXISTS "${_upstream_lib_cmake}")
  file(GLOB _upstream_files "${_upstream_lib_cmake}/*")
  if(_upstream_files)
    file(COPY ${_upstream_files} DESTINATION "${_share_cmake_dir}")
  endif()
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
endif()

# Also handle the debug variant created by multi-config installs.
set(_upstream_debug_lib_cmake "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/DagIR")
if(EXISTS "${_upstream_debug_lib_cmake}")
  file(GLOB _upstream_debug_files "${_upstream_debug_lib_cmake}/*")
  if(_upstream_debug_files)
    file(COPY ${_upstream_debug_files} DESTINATION "${_share_cmake_dir}")
  endif()
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
endif()

# Provide a minimal CMake package config if upstream did not install one.
# Note: postpone writing the final package config until after running the
# vcpkg fixups so the helper won't rewrite or mangle the files we create.

# Optionally install samples when the "samples" feature is enabled.
if(VCPKG_FEATURE_FLAGS)
  list(FIND VCPKG_FEATURE_FLAGS "samples" _has_samples)
else()
  # Older vcpkg versions expose selected features via the FEATURES variable
  if(DEFINED FEATURES)
    list(FIND FEATURES "samples" _has_samples)
  endif()
endif()

if(NOT _has_samples EQUAL -1)
  message(STATUS "vcpkg: installing samples because 'samples' feature is enabled")
  file(COPY "${SOURCE_PATH}/samples" DESTINATION "${CURRENT_PACKAGES_DIR}/share/dagir/")
endif()

# Ensure a debug share directory exists for multi-config fixups. Some vcpkg
# helper scripts expect a `/debug/share/<port>` layout to be present when the
# build is evaluated in a debug context; create it (empty) so the helper
# doesn't error when no debug files were installed.
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/dagir")

# Run vcpkg helper to normalize installed CMake files into the vcpkg expected
# layout (share/<port>/cmake) and perform any additional fixups. Use the
# builtin `vcpkg_fixup_cmake_targets` helper shipped with vcpkg scripts so
# no extra port dependency is required.
vcpkg_fixup_cmake_targets()

# Remove any accidental debug/include or debug/share directories created by
# the install step to silence post-build validation warnings.
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

# Install copyright/license into share/<port>/copyright as recommended by vcpkg.
if(EXISTS "${SOURCE_PATH}/LICENSE")
  vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
endif()

# End of portfile.

# Write final minimal CMake package config in the expected share location.
set(_targets_file "${_share_cmake_dir}/DagIRTargets.cmake")
file(WRITE "${_targets_file}"
  "# Minimal imported targets for DagIR\n"
  "add_library(dagir::dagir INTERFACE IMPORTED)\n"
  "# Resolve the include directory relative to this file so the config is\n"
  "# relocatable and doesn't depend on absolute paths. From the installed\n"
  "# layout this file lives in: <prefix>/share/dagir, so ../../include\n"
  "# refers to <prefix>/include.\n"
  "set_target_properties(dagir::dagir PROPERTIES INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\")\n"
)

file(WRITE "${_share_cmake_dir}/DagIRConfig.cmake"
  "include(\"\${CMAKE_CURRENT_LIST_DIR}/DagIRTargets.cmake\")\n"
)
