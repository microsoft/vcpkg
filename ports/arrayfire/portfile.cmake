vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO arrayfire/arrayfire
  REF 59ac7b980d1ae124aae914fb29cbf086c948954d # v3.7.3
  SHA512 e8c209a5249046cb8d68877463b4f4921cfc363ec2f9b070ba67c9e00cbe7b44d5db209922dabc47e53977ff918e7f0d289f85c7571a826c2050d0ee8deae3e0
  HEAD_REF master
  PATCHES build.patch
  )

# arrayfire cpu thread lib needed as a submodule for the CPU backend
vcpkg_from_github(
  OUT_SOURCE_PATH CPU_THREADS_PATH
  REPO arrayfire/threads
  REF b666773940269179f19ef11c8f1eb77005e85d9a
  SHA512 b3e8b54acf3a588b1f821c2774d5da2d8f8441962c6d99808d513f7117278b9066eb050b8b501bddbd3882e68eb5cc5da0b2fca54e15ab1923fe068a3fe834f5
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
  -DAF_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT} # for CMake configs/targets
  )

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
vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    ${AF_DEFAULT_VCPKG_CMAKE_FLAGS}
    ${AF_BACKEND_FEATURE_OPTIONS}
  )
vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Copyright and license
file(INSTALL ${SOURCE_PATH}/COPYRIGHT.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
