vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-core_1.0.0-beta.8
    SHA512 fd882e37332fd5f35627b94c96cfae78178d9bc551cc9a27480f2ef08d496ea2379dc8d0e6a237e902ce063ae87ed6f9e8dc0b91e2e16bd8638e839f8d9e4c2a
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
