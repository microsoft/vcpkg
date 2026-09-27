string(REPLACE "." "_" release_tag "xmlsec_${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF "${release_tag}"
    SHA512 7b0924a5cdfae7d4054ad5381069b5830aa4a4ed03ae9e37498cfc47a29d438f761fb0864ec1e94293a83d07c5ddddd6f3ef3853d2472c16f346e975d64ff09f
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
