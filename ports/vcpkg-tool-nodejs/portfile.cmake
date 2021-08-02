set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(PROGNAME node)
set(PROG_VERSION 14.17.4)

set(BREW_PACKAGE_NAME "${PROGNAME}")
set(APT_PACKAGE_NAME "${PROGNAME}")

if(VCPKG_CROSSCOMPILING)
    message(FATAL_ERROR "This is a host only port!")
endif()

set(BASE_URL "https://nodejs.org/dist/v${PROG_VERSION}/")
set(ARCHIVE "")
set(ARCHIVE_EXT "")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "^x86$|arm")
    set(ARCHIVE "node-v${PROG_VERSION}-win-x86")
    set(ARCHIVE_EXT ".zip")
    set(HASH 82ea09a10f20ecab860b9e15b2cc72eec4a60ac5f20680f7846f37c5c1422d38d448cd7a71382cbb41101c1382412368bb74bf1a0bd7698f7ba882e022ae7304)
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCHIVE "node-v${PROG_VERSION}-win-x64")
    set(ARCHIVE_EXT ".zip")
    set(HASH 9a067c9ac5abc8d6af756b9a5344beee552f877a54833bdfa3a88e694359831f4edc9fac9c2c29b2f02f859e79bfeb4b91735e70c02c9daddf3e82efbfcbe46c)
elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCHIVE "node-v${PROG_VERSION}-darwin-x64")
    set(ARCHIVE_EXT ".tar.gz")
    set(HASH 0f786b639249da4dc26f626137098a64ef41b41545b94677db92ea6f9e5a8515b6262bb09ef06a9ed7875ab1aa6d459e47bfb4380e413a74f89e13c6c4bd1ad3)
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCHIVE "node-v${PROG_VERSION}-linux-x64")
    set(ARCHIVE_EXT ".tar.xz")
    set(HASH 0f786b639249da4dc26f626137098a64ef41b41545b94677db92ea6f9e5a8515b6262bb09ef06a9ed7875ab1aa6d459e47bfb4380e413a74f89e13c6c4bd1ad3)
else()
    message(FATAL_ERROR "Target not yet supported by '${PORT}'")
endif()
set(URL "${BASE_URL}${ARCHIVE}${ARCHIVE_EXT}")
message(STATUS "URL: '${URL}'")

vcpkg_download_distfile(ARCHIVE_PATH
  URLS "${URL}"
  SHA512 "${HASH}"
  FILENAME "${ARCHIVE}${ARCHIVE_EXT}"
  ALWAYS_REDOWNLOAD
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
message(STATUS "ARCHIVE_PATH: '${ARCHIVE_PATH}'")

vcpkg_execute_in_download_mode(
    COMMAND ${CMAKE_COMMAND} -E tar xzf "${ARCHIVE_PATH}" 
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools"
)
file(GLOB_RECURSE folders "${CURRENT_PACKAGES_DIR}/tools/*" LIST_DIRECTORIES true)
message(STATUS "Files and Folders: '${folders}'")

file(RENAME "${CURRENT_PACKAGES_DIR}/tools/${ARCHIVE}" "${CURRENT_PACKAGES_DIR}/tools/node")
