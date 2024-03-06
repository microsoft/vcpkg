vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO criticalstack/libevhtp
    REF  e200bfa85bf253e9cfe1c1a9e705fccb176b9171
    SHA512 d77d6d12dcc2762c8311a04cd3d33c7dfde7b406dbbb544d683e6a3b8e5912ba37a196470bc5aca92b58bd9659fbb396e5a11234b98435534f535046d6dab6eb
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
    openssl EVHTP_DISABLE_SSL
    thread  EVHTP_DISABLE_EVTHR
    regex   EVHTP_DISABLE_REGEX
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
vcpkg_fixup_pkgconfig()
