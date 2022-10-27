vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numactl/numactl
    REF v${VERSION}
    SHA512 de89bd9f4a9be0e27b21d096aa17a554c209414b5d08b6a2dbd03f8f4830fe4fc5adc88fa8cb08ae1cf75884835dacbde5b6f5d31386244a2582924d2260fcb6
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.GPL2" "${SOURCE_PATH}/LICENSE.LGPL2.1")
