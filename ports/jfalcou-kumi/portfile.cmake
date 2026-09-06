vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/kumi
    REF "v${VERSION}"
    SHA512 e34b4a5886dc9051453d6e27d3618c0fc09762e31cad6760cac25f5edb5b3c086ea5c0eaa75947d76d130e45732a0299224a5317cbeb2d23bbe937c6c11d1b6e
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
