vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ibireme/yyjson
    REF "${VERSION}"
    SHA512 26c93768e96080ca88e9c9acf6620ca26c54a7198bb7a5efe0294bf89102ab30e15f196597a79171b7e51f3dca1b5b0075136701007ecdc142293156031e21de
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
