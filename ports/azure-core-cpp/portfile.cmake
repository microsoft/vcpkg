vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-core_1.10.1
    SHA512 498deebd853070b367f4fc07ac6b54a8ec4850ad5152da81728e909838f89aa0c1d2c2996267ad343bb06f6ebaedf151973359298dee6ad3b49949af016eb568
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl BUILD_TRANSPORT_CURL
        winhttp BUILD_TRANSPORT_WINHTTP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/sdk/core/azure-core/"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DWARNINGS_AS_ERRORS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
