vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Sigmyne/redisx
    REF "v${VERSION}"
    SHA512 9dbbe4fb4a80c3c9d4ca3f28e11d0403f724bb219099d04bbf49fb78d41fc4f749bc6d77787d5eb1db51ec85898eb4e5eab80603c39e85c70bc02333de160e51
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tls              ENABLE_TLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_CLI=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/redisx" PACKAGE_NAME "redisx")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
