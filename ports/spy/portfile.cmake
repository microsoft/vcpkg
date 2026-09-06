vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/spy
    REF "${VERSION}"
    SHA512 f997d61a73fafecb9af837b92ae9ceee515380852d900fc1778950885fbb62f1121e8923a991500d7380396d847c65e7fd33d41b616b2f66d0234c5a947e0dfd
    HEAD_REF main
)

# Header-only: the headers are copied and the package files are written here. Configuring the
# project's own CMake would pull copacabana in for nothing, SPY having no test to run from here.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/spy-config-version.cmake.in"
               "${CURRENT_PACKAGES_DIR}/share/${PORT}/spy-config-version.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/spy-config.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
