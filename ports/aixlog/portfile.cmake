include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO badaix/aixlog
    REF  v1.2.1
    SHA512 776558fdd911f0cc9e8d467bf8e00a1930d2e51bb8ccd5f36f95955fefecab65faf575a80fdaacfe83fd32808f8b9c2e0323b16823e0431300df7bc0c1dfde12
    )
    
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME aixlog)
