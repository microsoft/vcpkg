vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arrayfire/arrayfire
    REF v3.7.1
    SHA512 0a4d03ade95c6e587715865e039ba03beb5194040545c4c20f1729f0a3c953112624259e6068a6ce93d41838001fc9ffa1fbf122eabf1b08526cb9e0ba51c77e
    HEAD_REF master
)

############################### Grab submodules ##############################
# spdlog
vcpkg_from_github(
  OUT_SOURCE_PATH SPDLOG_PATH
  REPO gabime/spdlog
  REF cbe9448650176797739dbab13961ef4c07f4290f
  SHA512 a4719fe9083c662603b4819a58c5df8558262192f16a7d4b678ed761b042660727e0f614d106125b3756da3a01d56370bb46789d4b03bb468a170ad7b90172f3
  HEAD_REF master
  )
# Copy submodule path into extern
file(RENAME ${SPDLOG_PATH} ${SOURCE_PATH}/extern/spdlog)

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

# arrayfire forge
vcpkg_from_github(
  OUT_SOURCE_PATH FORGE_PATH
  REPO arrayfire/forge
  REF 173ddaa199b10115abdd3c5d34287a7950f6bff3
  SHA512 f2b5a5c2d22e9325940e334e8cf0d802feced6f22f42569f2027b7e53e4ca3bc42077fa72c88d40720599a234b71c668785db611c2663896c34d62f8b4d91ca7
  HEAD_REF master
  )
# Copy submodule path into extern
file(RENAME ${FORGE_PATH} ${SOURCE_PATH}/extern/forge)

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

# nvidia cub
vcpkg_from_github(
  OUT_SOURCE_PATH CUB_PATH
  REPO NVlabs/cub
  REF ea48955fe5814b2319f77a68bd7094f5fdbf1b08
  SHA512 8131c7cc765fe1e682159da4178de7efea21d486eee66367251328f96f0e295faeb7e56a0cd48aa1313aa3319450200dc87e9dbb9ea5ba20916ccf0b8f1c0478
  HEAD_REF master
  )
# Copy submodule path into extern
file(RENAME ${CUB_PATH} ${SOURCE_PATH}/src/backend/cuda/cub)

# arrayfire assets
vcpkg_from_github(
  OUT_SOURCE_PATH ASSETS_PATH
  REPO arrayfire/assets
  REF cd08d749611b324012555ad6f23fd76c5465bd6c
  SHA512 93d1e6785fbfbf22e0c7080243d29d99c7808829cb3345760cd29c06ce5d0aab7a55cae28ab9f12263de47ec3d95b30bb907b1b92ad03193662a583bd3136ce9
  HEAD_REF master
  )
# Copy submodule path into extern
file(RENAME ${ASSETS_PATH} ${SOURCE_PATH}/assets)

################################### Build ###################################
# Default flags
set(AF_DEFAULT_VCPKG_CMAKE_FLAGS
  -DBUILD_TESTING=OFF
  -DBUILD_DOCS=OFF
  -DAF_BUILD_FORGE=OFF     # fixme - can we use forge? we can probably build graphics things too.
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
