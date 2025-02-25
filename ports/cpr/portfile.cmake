vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcpr/cpr
    REF ${VERSION}
    SHA512 30caf9257e5e45f809f541a32daf8c6c7001fbaafef0ee0ae8dd59f49736953120cb7c8849ddbff2f7fbc54d80902ec2b905f90f68f63d1f2a2dc63eda577713
    HEAD_REF master
    PATCHES
        disable_werror.patch
        fix-static-build.patch
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
