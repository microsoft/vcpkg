vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ibireme/yyjson
    REF 0.4.0
    SHA512 0d5824158f7491926e6d2a1fd1a1e637fdb2ce5a6bd1ec88301231dd567345295751c1e8f12f8a1ffc7179970081cf50b97301691a47ae5d418331f0d41479ce
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
