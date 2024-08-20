vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ryanhaining/cppitertools
    REF 539a5be8359c4330b3f88ed1821f32bb5c89f5f6
    SHA512 cab0cb8a6b711824c13ca013b3349b9decb84f2dab6305bfb1bdd013f7426d5b199c127dadabeaaafc2e7ff6ad442222dd0fffee9aaacfa27d3aeb82c344ae4f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dcppitertools_INSTALL_CMAKE_DIR=share
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/share/cppitertools-config-version.cmake")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/cppitertools"
    RENAME copyright)
