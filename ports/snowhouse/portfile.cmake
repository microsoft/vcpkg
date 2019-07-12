include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO banditcpp/snowhouse
  REF da65e99e9da63028062b2a18e275a8f6010e0fb5
  SHA512 232243000954348fcc684c6e0bcfe70f9f717a32b1d42d8e6f766fcd431f4e0accd3c2d6495e88875e6b08c3769f4eb1ff4e01c3c1836ee6a76cf14dee0a1089
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/snowhouse DESTINATION ${CURRENT_PACKAGES_DIR}/include/ FILES_MATCHING PATTERN *.h)

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/snowhouse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snowhouse/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/snowhouse/copyright)