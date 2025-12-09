if(NOT VCPKG_TARGET_IS_LINUX)
    message(FATAL_ERROR "${PORT} currently only supports Linux platform.")
endif()

vcpkg_download_distfile(ADD_CSTDINT_PATCH
    URLS https://github.com/pistacheio/pistache/commit/dabe9fcd3eaaa6b0b8723369b2565778341630c0.diff?full_index=1
    FILENAME pistache-cstdint-dabe9fcd3eaaa6b0b8723369b2565778341630c0.diff
    SHA512 1cef4b084050a5cb409a2f055e12f03184ad3cd07c8b896c38152f9c0c630d812a73fb78ccb3e7270ffe8001d877c3da173be06810744c2e0807a20e488ee66d
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pistacheio/pistache
    REF 9dc080b9ebbe6fc1726b45e9db1550305938313e #2021-03-31
    SHA512 b55c395fb98af85317590ed2502564af5e92e30a35618132568c6ab589a6d0971570ad20ddbd1f49d9dd8cf54692866c69cfc1350c6fdccf9efb039aacf153b4
    HEAD_REF master 
    PATCHES
        "${ADD_CSTDINT_PATCH}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
