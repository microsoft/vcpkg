include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO banditcpp/snowhouse
  REF 36da05054dd8f019dddfabf0f3fc9d020d0b2f93
  SHA512 e3847d50a34251b1f49e3fd3e45d3a6e61422418059208de25a9c7947de2ad002fdc81f85f69dfd2357e00a014f1da2643b2b48c0383b2ec210fcc64be796578
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/snowhouse DESTINATION ${CURRENT_PACKAGES_DIR}/include/ FILES_MATCHING PATTERN *.h)

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/snowhouse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snowhouse/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/snowhouse/copyright)