vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ibireme/yyjson
    REF "${VERSION}"
    SHA512 4b9ca85096ccfe2f513a5869eb63b175f44c67785940e02414f6a586d7dd7b772fed77a1775d9416a5f1bf17f20e18a31f0dc4e65be263019d9b95bf95366219
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        reader       YYJSON_DISABLE_READER
        writer       YYJSON_DISABLE_WRITER
        fast-fp-conv YYJSON_DISABLE_FAST_FP_CONV
        non-standard YYJSON_DISABLE_NON_STANDARD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DYYJSON_BUILD_TESTS=OFF
        -DYYJSON_BUILD_MISC=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
