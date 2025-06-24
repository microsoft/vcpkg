vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "libunwind/libunwind"
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 50bb802a821939d38e38ce9f906934eea6a4e815f9401c18d5de6205ae0b5c7594e94d37bbf8f9da4012c0adebac208077548771d21bb89a4dedeb27645ceb25
    PATCHES
        liblzma.diff
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-documentation
        --disable-tests
        --disable-zlibdebuginfo
        --enable-minidebuginfo
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
