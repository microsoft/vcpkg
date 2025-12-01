vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcpr/cpr
    REF ${VERSION}
    SHA512 4e9849f93181374699ed8564e58920eb9617aa2564221b23f8ef81871a9ae1015cc32ee820c700a325d0a9665eac4681efac6a92157040c6de83941590461b7e
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
