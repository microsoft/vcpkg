vcpkg_download_distfile(STATIC_LIBRARY_PATCH
    URLS https://github.com/pistacheio/pistache/commit/2477494e5b5cc1f77a4b38a8176a60c6c8e36841.diff?full_index=1
    FILENAME pistache-static-library-2477494e5b5cc1f77a4b38a8176a60c6c8e36841.diff
    SHA512 30e08a1516b2fdcf40aa632cb1944d2a628a193d9b08f42d5a18956f00e7098f7f49ac0d9821e2eb4b87bca644c2f83746e41bd25421fc5872208b51bcb59b22
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pistacheio/pistache
    REF "v${VERSION}"
    SHA512 2f6d3178354bd4fe78e48fbb0b15055c2a92bee4f4fcee26c3bcc2076df8ca47ef4cac931ee565f5003837beb78a2456ed7d2b6a39083860631426fd074b497c
    HEAD_REF master
    PATCHES
        "${STATIC_LIBRARY_PATCH}"
)

if(VCPKG_TARGET_IS_WINDOWS)
    # pistachelog.dll is a resource-only Windows Event Log message DLL.
    set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
    endif()
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPISTACHE_BUILD_TESTS=false
        -DPISTACHE_BUILD_EXAMPLES=false
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
