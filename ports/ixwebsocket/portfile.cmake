vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO machinezone/IXWebSocket
    REF 2f560ff4c07e5446f2539505cb4f64f80b54ca8e #v11.4.2
    SHA512 afa19cc161b9e49eafacc113583bbf68a34d83a9535c5c4f1f1cd57f943a5ad91c3117c0e2b47b2975a65f0284aec1200f6f8f5768afa7d6aebcbb823934036a
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl   USE_OPEN_SSL
        mbedtls   USE_MBED_TLS
        sectransp USE_SECURE_TRANSPORT
)

if("sectransp" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_OSX)
    message(FATAL_ERROR "sectransp is not supported on non-Apple platforms")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
      -DUSE_TLS=1
    MAYBE_UNUSED_VARIABLES
      USE_SECURE_TRANSPORT
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ixwebsocket)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
