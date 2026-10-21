# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/sml
    REF "v${VERSION}"
    SHA512 4e0da6178513fffd3f6830d155d0f77e5e92b774e54f2e3d56510b6a94072b68d197c3e8407c7756639f90efef6e0d8a960ed7061abd5f633ae24a326bbb2530
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/boost/sml.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
