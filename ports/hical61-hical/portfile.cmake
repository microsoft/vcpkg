vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Hical61/Hical
    REF "v${VERSION}"
    SHA512 51d22669034176e977f3ab0747f835162727870211668d53a8f9464031eae92f26c771438f1cdeb0a742af1f1007d8579499c62e94220f4af0913d52ff2070fd
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        database HICAL_WITH_DATABASE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHICAL_BUILD_TESTS=OFF
        -DHICAL_BUILD_EXAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME hical
    CONFIG_PATH lib/cmake/hical
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
