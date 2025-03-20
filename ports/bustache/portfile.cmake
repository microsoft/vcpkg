vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jamboree/bustache
    REF 1a6d4422bff46c7c8f37d2ba48c910532bdc8b37
    SHA512 a6eccc815c9ee1d7de9e1c8e2affc6d1a393fe3017eb492cbb3698282d567304a6b234d37aac6a48cd315c68187ec89f62c63ea4e9786bbb963b35f7d18990d9

    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fmt BUSTACHE_USE_FMT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        BUSTACHE_USE_FMT
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/bustache")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

# No license file --> use Readme
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
