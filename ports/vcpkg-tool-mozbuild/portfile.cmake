set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(PROGNAME mozbuild)
set(EXE_NAME mozmake)
set(ARCHIVE MozillaBuildSetup-${VERSION})
set(BASE_URL "https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-")
set(URL "${BASE_URL}${VERSION}.exe")
set(HASH 247a8c08e3cf9ff69bee106e6c24ea392bb13e6ed19c2c42750d013989ad18923a05631fe4edf622e82321e7748936ff0cdb09607bfbbde00cdb8a6fd4f9b79d)

if(VCPKG_CROSSCOMPILING)
    message(FATAL_ERROR "This is a host only port!")
endif()

vcpkg_download_distfile(ARCHIVE_PATH
  URLS "${URL}"
  SHA512 ${HASH}
  FILENAME "${ARCHIVE}.7z.exe"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/mozbuild")

vcpkg_find_acquire_program(7Z)

vcpkg_execute_in_download_mode(
    COMMAND "${7Z}" x "${ARCHIVE_PATH}" -aoa
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/mozbuild"
)
