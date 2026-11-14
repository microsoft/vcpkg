vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/tts
    REF "${VERSION}"
    SHA512 2b692bad6c7c64b766915881c614b5edeb95443ba7e3a42f0ad11677923e4098c1319060a5755f89acc7c2d1fb2ab895ad7ab7560e99e09f32046302f274c17c
    HEAD_REF main
)

# The port is named for its owner, vcpkg asking for that when a name is ambiguous, but what it installs
# keeps the project's own name: find_package(tts CONFIG) is what a consumer writes.
# Header-only: the headers are copied and the package files are written here. Configuring the
# project's own CMake would pull copacabana in for nothing, there being no test to run from here.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/tts-config-version.cmake.in"
               "${CURRENT_PACKAGES_DIR}/share/tts/tts-config-version.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/tts-config.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/tts")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
