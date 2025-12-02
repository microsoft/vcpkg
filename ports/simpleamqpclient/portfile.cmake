vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alanxz/SimpleAmqpClient
    REF "v${VERSION}"
    SHA512 f561a45774da55e7b846e6cab7fbcdabb0a6deb462450ca9e8a0e37acccb33957daeb29f31b24671934139f29f8c02c14ba53ce5fdf05b5349f7d6c041e4a6ab
    HEAD_REF master
    PATCHES
        rabbitmqc-use-find-package-config.patch
)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl ENABLE_SSL_SUPPORT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_SHARED_LIBS=ON
        -DENABLE_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-MIT")