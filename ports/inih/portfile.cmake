vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO benhoyt/inih
    REF "r${VERSION}"
    SHA512 0aede2f2dbb70e6ee855743045d423a0f399c6361f84813be5b912ca84b4dfe40013857b91390d9b156f8bc53067582ea66e6c7de339f4b0fb7436b10143a059
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpp with_INIReader
)

string(REPLACE "OFF" "false" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
string(REPLACE "ON" "true" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-Dcpp_std=c++11"
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

string(COMPARE EQUAL "${VCPKG_BUILD_TYPE}" "" INIH_CONFIG_DEBUG)
configure_file("${CURRENT_PORT_DIR}/unofficial-inihConfig.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-inih/unofficial-inihConfig.cmake" @ONLY)

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
