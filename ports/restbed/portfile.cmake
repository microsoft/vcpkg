vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl     BUILD_SSL 
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Corvusoft/restbed
    REF "${VERSION}"
    SHA512 989027c926b97a9dd02951c881dc41819014783da4848cc9ee50776545ba206830d35c2e775abd8c0f705f7b0611d5cd335dd1eb305cdcbf2c86100abaf1623c
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/Findopenssl.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-restbed)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
