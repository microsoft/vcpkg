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
    set(HASH 76575afb5711c6fbccd45ef319d6c3960d0363808a0703e7e9ed5c637fe19af63a8ff6eb08182df77c7620d50a42bf9fd324489466556a1b5895f0f2aebb8a5a)
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCHIVE "node-v${PROG_VERSION}-linux-x64")
    set(ARCHIVE_EXT ".tar.xz")
    set(HASH 696af62f78147dc20e15364ba7fea6f707b0d5e3c9ae925975d64ec7dc90db4f27a3e5e90307a26bf48b05e0096ab34144d29cd9379b70b384cbd3144bf8cd85)
else()
    message(FATAL_ERROR "Target not yet supported by '${PORT}'")
endif()
set(URL "${BASE_URL}${ARCHIVE}${ARCHIVE_EXT}")
message(STATUS "URL: '${URL}'")

vcpkg_download_distfile(ARCHIVE_PATH
  URLS "${URL}"
  SHA512 "${HASH}"
  FILENAME "${ARCHIVE}${ARCHIVE_EXT}"
  #ALWAYS_REDOWNLOAD
  #SKIP_SHA512
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
