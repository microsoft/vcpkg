vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flashlight/text
    REF v${VERSION}
    SHA512 d9ed9b687c441e356b19a035ecef1abc76d90e3e0d8a9c32899bd7a81e379a9ae51bc6d68e7bae10cf83b87ec76289afbd81909d70799ca8d24f996e8667ad85
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        kenlm FL_TEXT_USE_KENLM
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFL_TEXT_BUILD_TESTS=OFF
        -DFL_TEXT_BUILD_STANDALONE=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
    OPTIONS_RELEASE
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}"

)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
