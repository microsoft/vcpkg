vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO idealvin/coost
    REF v2.0.3
    SHA512 b6d38181a8da7dd06cc6ee9c0310ebbc87db5fc0e82e1deb9afba7813d0741fed194887770c55a9a1c61ad677b365cac5ba4f0cf3f32ee376d86c6822d9e30c4
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

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
