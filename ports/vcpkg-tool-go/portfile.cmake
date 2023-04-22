set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(VCPKG_CROSSCOMPILING)
    message(FATAL_ERROR "This is a host only port!")
endif()

set(PROGRAM_NAME "go")
set(BREW_PACKAGE_NAME "go")
set(APT_PACKAGE_NAME "golang-go")

set(BASE_URL "https://dl.google.com/go/")

if (VCPKG_TARGET_IS_WINDOWS)
    set(OS "windows")
elseif (VCPKG_TARGET_IS_OSX)
    set(OS "darwin")
elseif (VCPKG_TARGET_IS_LINUX)
    set(OS "linux")
elseif (VCPKG_TARGET_IS_FREEBSD)
    set(OS "freebsd")
endif()

set("EXT_windows-x86"   "386.zip")
set("EXT_windows-x64"   "amd64.zip")
set("EXT_windows-arm"   "386.zip")
set("EXT_windows-arm64" "arm64.zip")
set("EXT_darwin-x64"    "amd64.tar.gz")
set("EXT_darwin-arm64"  "arm64.tar.gz")
set("EXT_linux-x86"     "386.tar.gz")
set("EXT_linux-x64"     "amd64.tar.gz")
set("EXT_linux-arm"     "armv6l.tar.gz")
set("EXT_linux-arm64"   "arm64.tar.gz")
set("EXT_freebsd-x86"   "386.tar.gz")
set("EXT_freebsd-x64"   "amd64.tar.gz")

if (NOT DEFINED "EXT_${OS}-${VCPKG_TARGET_ARCHITECTURE}")
    message(FATAL_ERROR "Target not yet supported by '${PORT}'")
endif()

set(TARGET_EXT "${OS}-${EXT_${OS}-${VCPKG_TARGET_ARCHITECTURE}}")

set(ARCHIVE "go${VERSION}.${TARGET_EXT}")
set(URL "${BASE_URL}${ARCHIVE}")

include("${CURRENT_PORT_DIR}/sha_manifest.cmake")

vcpkg_download_distfile(ARCHIVE_PATH
    URLS "${URL}"
    SHA512 "${HASH_${TARGET_EXT}}"
    FILENAME "vcpkg-tool-${ARCHIVE}"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
message(STATUS "ARCHIVE_PATH: '${ARCHIVE_PATH}'")

vcpkg_execute_in_download_mode(
    COMMAND ${CMAKE_COMMAND} -E tar xzf "${ARCHIVE_PATH}"
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools"
)
