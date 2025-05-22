vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LLNL/fpzip
    REF "${VERSION}"
    SHA512 1f37687cbd668a9ab14dad4511f94ede6bd527add5616430a5322ed9620b092bec5d8c286248e8244e8df5053d327bc9ad6cac6820f54d946e43b6d0f8e7174f
    HEAD_REF develop
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pic    FPZIP_ENABLE_PIC
	cmdutils BUILD_UTILITIES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
