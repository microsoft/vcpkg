# Nakama C/C++ client (Heroic Labs): https://github.com/heroiclabs/nakama-cpp

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO heroiclabs/nakama-cpp
    REF v2.9.0
    SHA512 e69cb549d3c451d9e6f16dfc3afc1ed1f1a4d45a92d9967b5090c748dc59a66de51ea27b01d9734718f59887cf7fa2b5c3edb75392e60dd84efe64e45fe1fc76
    HEAD_REF main
    PATCHES
        patches/001-use-vcpkg-toolchain.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl  WITH_HTTP_CURL
        wslay WITH_WS_WSLAY
        logs  LOGS_ENABLED
)

set(EXTRA_OPTS "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND EXTRA_OPTS -DCFG_WSLAY_CURL_IO=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCFG_CURL_SYSTEM=OFF
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME nakama-sdk)

if(EXISTS "${SOURCE_PATH}/LICENSE.txt")
    file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
else()
    file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
