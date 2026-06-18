vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ibireme/yyjson
    REF "${VERSION}"
    SHA512 a468477544f40a13595eb0afa74857b669b0cf0bf3258678541368863cc3a27fa6f43cc2ef1f4c6103c81b798cea2f67cc14268789de3965e1315a44972c713f
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
