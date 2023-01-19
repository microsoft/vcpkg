vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ibireme/yyjson
    REF 0.6.0
    SHA512 ad8b9d904ecd6c745d8b261d5c20879922db01a8e4f3d9df2949f2cc7ec40360411d571cb8d0a8d4e1bab39f9b8f9ddf4c54db42f4e5f35b1ea005197374ee17
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

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
