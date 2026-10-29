vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imakris/mexce
    REF "${VERSION}"
    SHA512 ae852c2128475111f5e2c897004ac81bb7bc4011537ad44643176d0241517bbca9fa9045751ad47b0e4dfa376ee69612a361ab64fc2ead4c65dd9a38d896bf21
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
