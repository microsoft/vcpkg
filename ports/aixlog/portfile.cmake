include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO badaix/aixlog
    REF  v1.2.2
    SHA512 384ffe4a40970150d7cbc64f5bd5a64486415f11487b5a432502f16e190f9a96383e65173cbb6624b4ec8bc5168addef93a895dc9b16f874e4a4c8d93be55dd6
    )
    
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME aixlog)
