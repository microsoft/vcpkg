vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arrayfire/arrayfire
    REF 11148d7e27be07775a5bd32ee58ef22ba6e889b0 # v3.7.2
    SHA512 bb6bfe213bf9787e89099b94d4bbbdf444565ddc32be1ea49b69a1951268b23423c14c3082f5da1412bb7077a0b7faa95b0f5dcc4ac2887a15d9285e9fc31545
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
  )

# bin/dll directory for Windows non-static builds for the unified backend dll
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(AF_BIN_DIR ${CURRENT_PACKAGES_DIR})
  set(AF_DEFAULT_VCPKG_CMAKE_FLAGS ${AF_DEFAULT_VCPKG_CMAKE_FLAGS} -DAF_BIN_DIR=${AF_BIN_DIR})
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
    OPTIONS ${AF_DEFAULT_VCPKG_CMAKE_FLAGS} ${AF_BACKEND_FEATURE_OPTIONS}
)  
vcpkg_install_cmake()

if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Copyright and license
file(INSTALL ${SOURCE_PATH}/COPYRIGHT.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME license)
