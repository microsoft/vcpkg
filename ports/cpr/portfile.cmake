vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcpr/cpr
    REF ${VERSION}
    SHA512 9907d2936f814924e82aaaf652149c119e2d9b94677efde0c80c570bc8cb50e4a36aa2520e2efb3f1fc82cba10ef61b9262705cd6e5cb49757b0c37af071ae22
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
