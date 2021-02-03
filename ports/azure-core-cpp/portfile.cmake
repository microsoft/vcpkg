vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-core_1.0.0-beta.5
    SHA512 e109ea215f3a2440d2b66cccfa6be9b4c143373105df962e47ddaf6668207171a1e8c9317a7799aa647b4669078871fde0c48e407c7966e377e7e6a9d8a67575
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
