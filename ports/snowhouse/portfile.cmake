include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO banditcpp/snowhouse
  REF v3.1.1
  SHA512 4547893c77eb7ddf7c1dac222ebd2456c518c38a12001b8a27b64d876ece93591ff624b911cb4f1ea3d7b635e92cc3ace536ca12e476bdfbce9789293b95b08f
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/snowhouse DESTINATION ${CURRENT_PACKAGES_DIR}/include/ FILES_MATCHING PATTERN *.h)

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/snowhouse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snowhouse/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/snowhouse/copyright)