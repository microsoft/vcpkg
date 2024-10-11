vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebookincubator/gloo
  REF 81925d1c674c34f0dc34dd9a0f2151c1b6f701eb
  SHA512 2783908e7e0d6bd7f8cf59f4e6a94c84908e459f394c294cdf34aa8d1943a193fb25d15a8662f5a32a82b23a2657e63b1aa562f3ad8953ef79c9f502d04fed20
  HEAD_REF master
)

# Determine which backend to build via specified feature
vcpkg_check_features(
  OUT_FEATURE_OPTIONS GLOO_FEATURE_OPTIONS
  FEATURES
  mpi USE_MPI
  redis USE_REDIS
  )

if ("cuda" IN_LIST FEATURES)
  list(APPEND GLOO_FEATURE_OPTIONS "-DUSE_CUDA=1" "-DUSE_NCCL=1")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${GLOO_FEATURE_OPTIONS}
  )
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/Gloo)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
