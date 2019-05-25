include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO banditcpp/snowhouse
  REF 36da05054dd8f019dddfabf0f3fc9d020d0b2f93
  SHA512 ea5d6b4b4560752925807f9ece201960764563650473fd80159cfafc0b960c8a3a8a719e937886f3af53ed1ae3d0e4b016a1611700318afa58a2e3365562a7c4
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/snowhouse DESTINATION ${CURRENT_PACKAGES_DIR}/include/ FILES_MATCHING PATTERN *.h)

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/snowhouse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snowhouse/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/snowhouse/copyright)