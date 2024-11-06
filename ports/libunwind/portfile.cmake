vcpkg_download_distfile(libunwind
    URLS "https://github.com/dotnet/runtime/commit/d63c235756d4c46b061bd503a2c47207df6b3324.diff?full_index=1"
    FILENAME "libunwind.diff"
    SHA512 268af5d4aa3bec16e34c50024c0a3662e9a6fa7d273bb405c25f02066100e6bcbb9a68bd10556e3f420d983b586dac856fc45dbd182798889e5542217f953b27
)

file(READ "${libunwind}" contents)
string(REPLACE "/src/native/external/libunwind" "" contents "${contents}")
file(WRITE "${CURRENT_BUILDTREES_DIR}/src/libunwind.diff" "${contents}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "libunwind/libunwind"
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 dd8332b7a2cbabb4716c01feea422f83b4a7020c1bee20551de139c3285ea0e0ceadfa4171c6f5187448c8ddc53e0ec4728697d0a985ee0c3ff4835b94f6af6f
    PATCHES
        liblzma.diff
        "${CURRENT_BUILDTREES_DIR}/src/libunwind.diff"
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
