vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flashlight/text
    REF v${VERSION}
    SHA512 465663e146efdc26a0faf01c8d3062945947204e8d6552a17f7bd567e5e4fdcfae75177ce7cbf2a3677166158e6b9322707974a21f9cd8a3b89b759bd61ed38d
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
