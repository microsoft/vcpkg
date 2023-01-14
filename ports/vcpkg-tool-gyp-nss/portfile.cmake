set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(PROGNAME gyp-nss)
set(PROG_VERSION b3177c3f6c2c45a8ca098ae0f0ebb4536c624762)
set(ARCHIVE gyp-nss-${PROG_VERSION})

vcpkg_download_distfile(ARCHIVE_PATH
  URLS "https://github.com/plq/gyp-nss/archive/${PROG_VERSION}.zip"
  SHA512 7cd05e1bdcdb579e8226ecae2e925285e164349927f60350b87703afe9cbdc308f044bc9f6455318f99778b7b49304003aab47f6c587a13e6fbdaaa1533c558d
  FILENAME "${ARCHIVE}.zip"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")

vcpkg_execute_in_download_mode(
    COMMAND "${CMAKE_COMMAND}" -E tar xzf "${ARCHIVE_PATH}"
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools"
)
file(GLOB_RECURSE folders "${CURRENT_PACKAGES_DIR}/tools/*" LIST_DIRECTORIES true)

file(RENAME "${CURRENT_PACKAGES_DIR}/tools/${ARCHIVE}" "${CURRENT_PACKAGES_DIR}/tools/gyp-nss")
