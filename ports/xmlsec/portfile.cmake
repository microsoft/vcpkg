string(REPLACE "." "_" release_tag "xmlsec_${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF "${release_tag}"
    SHA512 a13862f4c6278a5719897ec65df5ed31fb01bdb22a29a62f2cd1bf71a1c932eb8d887ce5e7ec2e0492a4a0d7f8b36f6889a708e29bb9d7d0f0bb61ca69a8423a
    HEAD_REF master
    PATCHES
        pkgconfig_fixes.patch
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tools"     BUILD_WITH_TOOLS
        "with-dl"   BUILD_WITH_DYNAMIC_LOADING
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DBUILD_WITH_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-xmlsec)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# unofficial legacy usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/xmlsec-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-xmlsec-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-xmlsec")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright")
