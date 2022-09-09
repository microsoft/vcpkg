vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL https://github.com/twig-energy/stronk
  REF f298bca3102b48ada516b0b42f2d5e6899cbbc44
  HEAD_REF main
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
  ${CURRENT_PACKAGES_DIR}/debug
)

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
