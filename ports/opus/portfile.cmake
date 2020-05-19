vcpkg_from_github(
  OUT_SOURCE_PATH
  SOURCE_PATH
  REPO
  xiph/opus
  REF
  5c94ec3205c30171ffd01056f5b4622b7c0ab54c
  SHA512
  2423b1fc86d5b46c32d8e3bde5fc2b410a5c25c001995ce234a94a3a6c7a8b1446fdf19eafe9d6a8a7356fe0857697053db5eb8380d18f8111818aa770b4c4ea
  HEAD_REF
  master)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  avx AVX_SUPPORTED
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
    PREFER_NINJA)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Opus)
vcpkg_copy_pdbs()

file(INSTALL
     ${SOURCE_PATH}/COPYING
     DESTINATION
     ${CURRENT_PACKAGES_DIR}/share/opus
     RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake
                    ${CURRENT_PACKAGES_DIR}/lib/cmake
                    ${CURRENT_PACKAGES_DIR}/debug/include)
