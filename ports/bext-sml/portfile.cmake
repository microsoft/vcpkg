# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/sml
    REF "v${VERSION}"
    SHA512 dd681d783aad4cd9f697ea28b728ca3cbd94fbee09ea23b66a5c9a51f4c9e30852826ac20937f783729082faf24e0440a27f9e7efdc946c55159f676d2b1d47f
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/boost/sml.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
