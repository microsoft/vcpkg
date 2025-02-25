vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pistacheio/pistache
    REF "v${VERSION}"
    SHA512 2f6d3178354bd4fe78e48fbb0b15055c2a92bee4f4fcee26c3bcc2076df8ca47ef4cac931ee565f5003837beb78a2456ed7d2b6a39083860631426fd074b497c
    HEAD_REF master
)

if ("ssl" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DPISTACHE_USE_SSL=true)
endif()

if ("rapidjson" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DPISTACHE_USE_RAPIDJSON=true)
else()
    list(APPEND BUILD_OPTIONS -DPISTACHE_USE_RAPIDJSON=false)
endif()

if ("brotli" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DPISTACHE_USE_CONTENT_ENCODING_BROTLI=true)
endif()

if ("zstd" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DPISTACHE_USE_CONTENT_ENCODING_ZSTD=true)
endif()

if ("deflate" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DPISTACHE_USE_CONTENT_ENCODING_DEFLATE=true)
endif()

if ("libevent" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DPISTACHE_FORCE_LIBEVENT=true)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${BUILD_OPTIONS}
        -DPISTACHE_BUILD_TESTS=false
        -DPISTACHE_BUILD_EXAMPLES=false
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
