vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO idealvin/coost
    REF 43a8bb4c8fceafe8a86752f522f744301d2b8a7f #v3.0.0
    SHA512 e34c65853d4280412219d35f55a745e20475474bb59c208562b78edf49bc54852ea1e5d58d7a4bb8bf771f8c51c4eae1ad7426902a32b99c3ee5358bb9426740
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libcurl WITH_LIBCURL
        openssl WITH_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSTATIC_VS_CRT=${STATIC_CRT}
    MAYBE_UNUSED_VARIABLES
        STATIC_VS_CRT
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/coost)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
