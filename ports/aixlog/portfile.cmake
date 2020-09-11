include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO badaix/aixlog
    REF 9e89f702b71320c49fee1d27cc2d1bffe330dcc6 # v1.2.4
    SHA512 77dbe9631bdabb5c7178a51ecd064be0e3baa76ffdae05d012ac55f6d3837c9c3fb0fd2a1993535756869fc944c89c89ca7093dddb1f1ac0fff5343328536d83
    )
    
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME aixlog)
