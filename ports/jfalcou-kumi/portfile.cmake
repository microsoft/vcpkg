vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/kumi
    REF "v${VERSION}"
    SHA512 de66cf46f5d17e5feeab7435585935c157fcad8c8871042237007dcb4abd7114f2d1dcddc819c020e7c74ac953a7bf1c0be340b529af362d7cfbbad7f16b91bb
    HEAD_REF main
)

# The port is named for its owner, vcpkg asking for that when a name is ambiguous, but what it installs
# keeps the project's own name: find_package(kumi CONFIG) is what a consumer writes.
# Header-only: the headers are copied and the package files are written here. Configuring the
# project's own CMake would pull copacabana in for nothing, there being no test to run from here.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/kumi-config-version.cmake.in"
               "${CURRENT_PACKAGES_DIR}/share/kumi/kumi-config-version.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/kumi-config.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/kumi")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
