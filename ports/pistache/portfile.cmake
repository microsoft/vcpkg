if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pistacheio/pistache
    REF "v${VERSION}"
    SHA512 2f6d3178354bd4fe78e48fbb0b15055c2a92bee4f4fcee26c3bcc2076df8ca47ef4cac931ee565f5003837beb78a2456ed7d2b6a39083860631426fd074b497c
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    # pistachelog.dll is a resource-only Windows Event Log message DLL.
    set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
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
