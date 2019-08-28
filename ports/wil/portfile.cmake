#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/wil
    REF 7a6f0679be9cd625f54a21bb0ce06c39958b13a5
    SHA512 155b8ed9f3622e7d802b41d6086f2b5984e52a3c21d068157d5d428a2efe24f1960186412c61719bf32a4c12c313930defa590d07d7b05a6376fe0ae68a85b2e
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wil RENAME copyright)