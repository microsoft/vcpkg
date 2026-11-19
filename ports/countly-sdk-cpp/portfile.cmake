vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Countly/countly-sdk-cpp
    REF "${VERSION}"
    SHA512 c7956e676ba90f442f00454c823be1239b583ce83235e7ba7aa73dc0885a1fc07bd7de0d903ca398039ff3e425fb3a23aaa736f9abf2778a2fea360ddd22f2b4
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sqlite COUNTLY_USE_SQLITE
        sqlite COUNTLY_USE_SYSTEM_SQLITE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCOUNTLY_USE_SYSTEM_JSON=ON
        -DCOUNTLY_BUILD_TESTS=OFF
        -DCOUNTLY_BUILD_SAMPLE=OFF
        # keeps the SDK's macOS Homebrew lookup from replacing vcpkg's OpenSSL
        "-DOPENSSL_ROOT_DIR=${CURRENT_INSTALLED_DIR}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME countly CONFIG_PATH lib/cmake/countly)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
