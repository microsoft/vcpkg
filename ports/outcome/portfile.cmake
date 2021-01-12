set(OUTCOME_GITCOMMIT ac552d1c69ef556a1327393a0c56092517ff92db)
set(OUTCOME_HASH 2d27434bcb2d5bc27015fedc221eafd221acb7c873277c4f0c78bc6aa657e6e962f0458e64b2de5f695600a5b15559cd0d3602f276f35c414dfafb34c2214e8c)

# Use Outcome's all sources tarball, not its github repo. The tarball includes all dependencies.
vcpkg_download_distfile(
  ALL_SOURCES_TARBALL
  URLS "https://github.com/ned14/outcome/releases/download/all_tests_passed_${OUTCOME_GITCOMMIT}/outcome-v2-all-sources-${OUTCOME_GITCOMMIT}.tar.xz"
  FILENAME "outcome-v2-all-sources-${OUTCOME_GITCOMMIT}.tar.xz"
  SHA512 ${OUTCOME_HASH}
)
vcpkg_extract_source_archive_ex(
  SKIP_PATCH_CHECK
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE "${ALL_SOURCES_TARBALL}"
  REF "outcome-${OUTCOME_GITCOMMIT}"
)

# Use Outcome's own build process, skipping examples and tests, bundling the embedded quickcpplib
# instead of git cloning from latest quickcpplib.
vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
        -DOUTCOME_BUNDLE_EMBEDDED_QUICKCPPLIB=On
)

vcpkg_install_cmake()

# Looks like vcpkg_fixup_cmake_targets() can't be run twice, so do this by hand
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cmake/quickcpplib" "${CURRENT_PACKAGES_DIR}/share/quickcpplib")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/cmakelib" "${CURRENT_PACKAGES_DIR}/share/quickcpplib/cmakelib")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/scripts" "${CURRENT_PACKAGES_DIR}/share/quickcpplib/scripts")

# Must come AFTER the above, as it appears to hose the lib/cmake directory
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/${PORT}" TARGET_PATH "share/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

# Fixup the exports files with our embedded quickcpplib unusualness
file(READ "${CURRENT_PACKAGES_DIR}/share/quickcpplib/quickcpplibExports.cmake" quickcpplibExports)
string(REPLACE "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)" "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)" quickcpplibExports "${quickcpplibExports}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/quickcpplib/quickcpplibExports.cmake" "${quickcpplibExports}")

file(READ "${CURRENT_PACKAGES_DIR}/share/outcome/outcomeExports.cmake" outcomeExports)
string(REPLACE "get_filename_component(_DIR \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)" "get_filename_component(_DIR \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\ninclude(\"\${_DIR}/../quickcpplib/quickcpplibExports.cmake\")" outcomeExports "${outcomeExports}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/outcome/outcomeExports.cmake" "${outcomeExports}")


file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
