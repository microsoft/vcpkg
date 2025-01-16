vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcpr/cpr
    REF ${VERSION}
    SHA512 cde62f13b43bad143695e54f5f69dfd250be52d2f6a76ebb3fde3db1e1059eb3c2e9d62e71f4c90f98a33f0053aea7c97bf55d8a7fa8584a37298e6a1bc3b18a
    HEAD_REF master
    PATCHES
        disable_werror.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl CPR_ENABLE_SSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPR_BUILD_TESTS=OFF
        -DCPR_USE_SYSTEM_CURL=ON
        ${FEATURE_OPTIONS}
        # skip test for unused sanitizer flags
        -DTHREAD_SANITIZER_AVAILABLE=OFF
        -DADDRESS_SANITIZER_AVAILABLE=OFF
        -DLEAK_SANITIZER_AVAILABLE=OFF
        -DUNDEFINED_BEHAVIOUR_SANITIZER_AVAILABLE=OFF
        -DALL_SANITIZERS_AVAILABLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpr)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
