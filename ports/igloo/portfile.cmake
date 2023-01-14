vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO joakimkarlsson/igloo
  REF igloo.1.1.1
  SHA512 69d8edb840aa1e2c1df4529a39b94e2d33dbc9fb5869ae91a0f062d29b7fbb73d4e2180080e7696cb69fbf5126c7c53c98dddb003e0e5e796812330e1a4ba32e
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/igloo DESTINATION ${CURRENT_PACKAGES_DIR}/include/ FILES_MATCHING PATTERN *.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/igloo/external/snowhouse)
file(WRITE "${CURRENT_PACKAGES_DIR}/include/igloo/external/snowhouse/snowhouse/snowhouse.h" "#include <snowhouse/snowhouse.h>")

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/igloo)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/igloo/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/igloo/copyright)