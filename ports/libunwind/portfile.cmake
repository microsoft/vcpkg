vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "libunwind/libunwind"
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 dd8332b7a2cbabb4716c01feea422f83b4a7020c1bee20551de139c3285ea0e0ceadfa4171c6f5187448c8ddc53e0ec4728697d0a985ee0c3ff4835b94f6af6f
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-tests
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()


file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
