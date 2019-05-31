include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO banditcpp/snowhouse
  REF 5a612c248524a3b1bdd388bc0ef5a9ea0d2fa684
  SHA512 fd737b0f433093246883975ec70a407a62547e768f538e0540ac0634db1578f0ea46979b7055ae428f146499a0df3b1d6292b8d38c22d346476211757a271d21
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/snowhouse DESTINATION ${CURRENT_PACKAGES_DIR}/include/ FILES_MATCHING PATTERN *.h)

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/snowhouse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snowhouse/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/snowhouse/copyright)