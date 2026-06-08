vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO corogram/corogram
    REF "v${VERSION}"
    SHA512 7a5c28fc63c5d3db00690a3c745a8b9f23f0984876c0b306acbc3edfdefd50afdc4905144d6d264ed066724c3c7ff9481a7dc04e57642773940867969473e911
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    redis COROGRAM_HAS_HIREDIS
    ed25519 COROGRAM_ED25519
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${FEATURE_OPTIONS}
    -DCOROGRAM_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME corogram
    CONFIG_PATH lib/cmake/corogram
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")