vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO arrayfire/arrayfire
  REF d99887ae431fcd58168b653a1e69f027f04d5188 # v3.8.0
  SHA512 d8ddf6ba254744e62acf5ecf680f0ae56b05f8957b5463572923977ba2ffea7fa37cc1b6179421a1188a6f9e66565ca0f8cd00807513ccbe66ba1e9bbd41a3da
  HEAD_REF master
  PATCHES
    build.patch
    Fix-constexpr-error-with-vs2019-with-half.patch
    fix-dependency-clfft.patch
)

# arrayfire cpu thread lib needed as a submodule for the CPU backend
vcpkg_from_github(
  OUT_SOURCE_PATH CPU_THREADS_PATH
  REPO arrayfire/threads
  REF b666773940269179f19ef11c8f1eb77005e85d9a
  SHA512 b3e8b54acf3a588b1f821c2774d5da2d8f8441962c6d99808d513f7117278b9066eb050b8b501bddbd3882e68eb5cc5da0b2fca54e15ab1923fe068a3fe834f5
  HEAD_REF master
)

# Get forge. We only need headers and aren't actually linking.
# We don't want to use the vcpkg dependency since it is broken in many
# environments - see https://github.com/microsoft/vcpkg/issues/14864. This
# can be relaxed when the issue is fixed. Forge and its dependencies
# are still runtime dependencies, so the user can use the graphics
# library by installing forge and freeimage.
vcpkg_from_github(
  OUT_SOURCE_PATH FORGE_PATH
  REPO arrayfire/forge
  REF 1a0f0cb6371a8c8053ab5eb7cbe3039c95132389 # v1.0.5
  SHA512 8f8607421880a0f0013380eb5efb3a4f05331cd415d68c9cd84dd57eb727da1df6223fc6d65b106675d6aa09c3388359fab64443c31fadadf7641161be6b3b89
  HEAD_REF master
)

################################### Build ###################################

# Default flags
set(AF_DEFAULT_VCPKG_CMAKE_FLAGS
  -DBUILD_TESTING=OFF
  -DAF_BUILD_DOCS=OFF
  -DAF_BUILD_EXAMPLES=OFF
  -DUSE_CPU_MKL=ON
  -DUSE_OPENCL_MKL=ON
  -DAF_CPU_THREAD_PATH=${CPU_THREADS_PATH} # for building the arrayfire cpu threads lib
  -DAF_FORGE_PATH=${FORGE_PATH} # forge headers for building the graphics lib
  -DAF_BUILD_FORGE=OFF
)

if("cpu" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
      list(APPEND AF_DEFAULT_VCPKG_CMAKE_FLAGS "-DMKL_THREAD_LAYER=Sequential")
    endif()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        list(APPEND AF_DEFAULT_VCPKG_CMAKE_FLAGS "-DINT_SIZE=8")
        # This seems scary but only selects the MKL interface. 4 = lp; 8 = ilp; Since x64 has ilp as the default use it!
    endif()
endif()

# bin/dll directory for Windows non-static builds for the unified backend dll
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(AF_BIN_DIR ${CURRENT_PACKAGES_DIR})
  list(APPEND AF_DEFAULT_VCPKG_CMAKE_FLAGS "-DAF_BIN_DIR=${AF_BIN_DIR}")
endif()

if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  message(WARNING "NOTE: Windows support with static linkeage is still experimental.")
endif()

# Determine which backend to build via specified feature
vcpkg_check_features(
  OUT_FEATURE_OPTIONS AF_BACKEND_FEATURE_OPTIONS
  FEATURES
    unified AF_BUILD_UNIFIED
    cpu AF_BUILD_CPU
    cuda AF_BUILD_CUDA
    opencl AF_BUILD_OPENCL
)

# Build and install
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${AF_DEFAULT_VCPKG_CMAKE_FLAGS}
    ${AF_BACKEND_FEATURE_OPTIONS}
  OPTIONS_DEBUG
    -DAF_INSTALL_CMAKE_DIR="${CURRENT_PACKAGES_DIR}/debug/share/${PORT}" # for CMake configs/targets
  OPTIONS_RELEASE
    -DAF_INSTALL_CMAKE_DIR="${CURRENT_PACKAGES_DIR}/share/${PORT}" # for CMake configs/targets
  MAYBE_UNUSED_VARIABLES
    AF_CPU_THREAD_PATH
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" 
    "${CURRENT_PACKAGES_DIR}/debug/examples" 
    "${CURRENT_PACKAGES_DIR}/examples" 
    "${CURRENT_PACKAGES_DIR}/debug/share" 
    "${CURRENT_PACKAGES_DIR}/debug/LICENSES")

# Copyright and license
file(INSTALL "${SOURCE_PATH}/COPYRIGHT.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
