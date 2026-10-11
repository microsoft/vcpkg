vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imakris/mexce
    REF "${VERSION}"
    SHA512 75edb2621c775e9fc7cb6a294974dcf41eae589935950c6117eaaff0a598667ba64b266b73ebb4eaa053e4a876b604a445e592c93eb669cff887b91314afdbe7
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        protected MEXCE_ENABLE_PROTECTED_EXPRESSIONS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DMEXCE_BUILD_ISSUER_TOOLS=OFF
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mexce)

if("protected" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/THIRD_PARTY_NOTICES.md"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/share/licenses")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
