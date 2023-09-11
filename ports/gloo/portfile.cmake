vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebookincubator/gloo
  REF 1da21174054eaabbbd189b7f657ea24842d821e2
  SHA512 ebd8369e413aee739a3928f8e6738c15708f009e0cd5a3763b8cadbe6f6d0a9d758585a7a2b0f7dd6d39a12882ff2f9497ab2d4edcebd4eb2a7237ab857f317e
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
