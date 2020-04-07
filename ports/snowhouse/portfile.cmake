include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO banditcpp/snowhouse
  REF cd0761b31a5bb2810a5a250a1951224257f596ce # v4.0.0
  SHA512 1038e786abe062bc58937980fea272992e9ab831f5b246ce959e7d335442e8b5b1bc614cdea2f08f7956b22d0b7ef52573bd4f216a1db0efa15b0fefad9b9cae
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/snowhouse DESTINATION ${CURRENT_PACKAGES_DIR}/include/ FILES_MATCHING PATTERN *.h)

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/snowhouse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snowhouse/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/snowhouse/copyright)