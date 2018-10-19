# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mandreyel/mio
    REF 365a80c9acaab2a7d23a40a3add7071f9b739f85
    SHA512 a134dde60e6ada796bffc795563e3c4d4d4f3abd07ef3da7c15472951bf3f13d9fd37a05de71cd662ec5ff6e7048cfb1e7af76a35259c0ff58a53df792a6640e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dmio.tests=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/mio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mio RENAME copyright)
