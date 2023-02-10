vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH
  SOURCE_PATH
  REPO
  lamarrr/STX
  REF
  v0.0.2
  SHA512
  d29a31aec3366d00b1dd87f0ba7a89e061bdee81a2c0981bffded2166a8125f8d7a6fdbd48f696ff969777cbd470e11cc00a1f65e6eae053955bfae2e3271d7b
  HEAD_REF
  main)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS 
    FEATURES 
        backtrace    STX_ENABLE_BACKTRACE)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS})

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/stx)
vcpkg_copy_pdbs()

file(
  INSTALL ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
  RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
