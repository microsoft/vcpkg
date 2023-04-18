
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(PROGNAME gyp-next)
set(GIT_REF ac262fe82453c4e8dc47529338d157eb0b5ec0fb)
set(ARCHIVE gyp-next-${GIT_REF})

vcpkg_download_distfile(ARCHIVE_PATH
  URLS "https://github.com/nodejs/gyp-next/archive/${GIT_REF}.zip"
  SHA512 5607762ab4ec7d67c09518832365bfa897e3d71b891d7ad8ec27cc41322c0f1113cd45048990d497d683cc4d02d98ed17f4f672f4e10f64736ee1e2af1578bd1
  FILENAME "${ARCHIVE}.zip"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")

vcpkg_execute_in_download_mode(
    COMMAND "${CMAKE_COMMAND}" -E tar xzf "${ARCHIVE_PATH}"
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools"
)
file(GLOB_RECURSE folders "${CURRENT_PACKAGES_DIR}/tools/*" LIST_DIRECTORIES true)
file(RENAME "${CURRENT_PACKAGES_DIR}/tools/${ARCHIVE}" "${CURRENT_PACKAGES_DIR}/tools/gyp-next")
