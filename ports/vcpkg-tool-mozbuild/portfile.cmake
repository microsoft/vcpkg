set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(PROGNAME mozbuild)
set(EXE_NAME mozmake)
set(PROG_VERSION 3.3)
set(ARCHIVE MozillaBuildSetup-${PROG_VERSION})
set(BASE_URL "https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-")
set(URL "${BASE_URL}${PROG_VERSION}.exe")
set(HASH ac33d15dd9c974ef8ad581f9b414520a9d5e3b9816ab2bbf3e305d0a33356cc22c356cd9761e64a19588d17b6c13f124e837cfb462a36b8da898899e7db22ded)

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
