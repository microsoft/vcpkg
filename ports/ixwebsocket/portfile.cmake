vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO machinezone/IXWebSocket
    REF v7.9.2
    SHA512 478aca334cc9e3244f403b88ec4d33fff2f6815b44ecd846d3c58cd763768e4bad50fec0c4ae570ade9aa8450315c3e70df76ed99de76bc93af705f882fefad1
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DUSE_TLS=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME ixwebsocket)
