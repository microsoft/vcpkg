vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-core_1.0.0-beta.6
    SHA512 91283c1520f594992a8ea939e1caccdf6574af992a722dcc76d08d3088161f0feb0991c88126c8294b4d1bf7e76ec6f96aa3c0065cdbd5fcc0f94af523f2f7db
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl BUILD_TRANSPORT_CURL
        winhttp BUILD_TRANSPORT_WINHTTP
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/sdk/core/azure-core/
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()

