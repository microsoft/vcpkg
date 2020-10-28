vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arrayfire/arrayfire
    REF v3.7.1
    SHA512 0a4d03ade95c6e587715865e039ba03beb5194040545c4c20f1729f0a3c953112624259e6068a6ce93d41838001fc9ffa1fbf122eabf1b08526cb9e0ba51c77e
    HEAD_REF master
    PATCHES submodules.patch
)

############################### Grab submodules ##############################
# TODO: try to remove me
# arrayfire glad
vcpkg_from_github(
  OUT_SOURCE_PATH GLAD_PATH
  REPO arrayfire/glad
  REF 6e58ccdfa8e65e1dc5d04a0b9c752c6508ef80b5
  SHA512 9eb022aed98eaa18b91712053d73137b085964cea76a2d8951b7693492ee54bd508a1af5615645d018c16341bc4d8d7ae3323a328ac2a5cfc89ef0141a8dbfb7
  HEAD_REF master
  )
# Copy submodule path into extern
file(RENAME ${GLAD_PATH} ${SOURCE_PATH}/extern/glad)

# arrayfire cpu threads
vcpkg_from_github(
  OUT_SOURCE_PATH CPU_THREADS_PATH
  REPO arrayfire/threads
  REF 6a967802fc161f08c5fa1c433601e233fda3eef6
  SHA512 397d787cbaa2fc628e3b82279fa5dd14a2ea8ee9c1d64c418674f53ba52a36dc120feadf9e00e2a55178cc3c9a989cf082a0f10e68782eb174ef0dc2c4b35e12
  HEAD_REF master
  )
# Copy submodule path into extern
file(RENAME ${CPU_THREADS_PATH} ${SOURCE_PATH}/src/backend/cpu/threads)

################################### Build ###################################
# Default flags
set(AF_DEFAULT_VCPKG_CMAKE_FLAGS
  -DBUILD_TESTING=OFF
  -DAF_BUILD_DOCS=OFF
  -DAF_BUILD_EXAMPLES=OFF
  )

# Determine which backend to build via specified feature
vcpkg_check_features(
  OUT_FEATURE_OPTIONS AF_BACKEND_FEATURE_OPTIONS
  FEATURES
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

# Copyright and license
file(INSTALL ${SOURCE_PATH}/COPYRIGHT.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/arrayfire RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/arrayfire RENAME license)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
