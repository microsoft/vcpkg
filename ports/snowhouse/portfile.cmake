include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO banditcpp/snowhouse
  REF v3.0.1
  SHA512 b20a703e79a2821bdc43b2a235ed7634499f877f9e96bd0d39eb563ce5c94d4577449cc15dc850176a1b44eb55cf3425885cb4d46a92444a7aa3001ce5d0a3eb
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/snowhouse DESTINATION ${CURRENT_PACKAGES_DIR}/include/ FILES_MATCHING PATTERN *.h)

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/snowhouse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snowhouse/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/snowhouse/copyright)