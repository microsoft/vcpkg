vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcpr/cpr
    REF 1e835390185c7002a97865c535842e4192d8933d #1.10.2
    SHA512 e2d3659c200fc92ac0f92794a9768eafc3dbe9006dfe201e740cd4ef104356179c36dff63d8b815ac6e22cd9e26e194f902045cda547764a38a94e3d4491bbac
    HEAD_REF master
    PATCHES
        001-cpr-config.patch
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
        -DCPR_FORCE_USE_SYSTEM_CURL=ON
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpr)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
