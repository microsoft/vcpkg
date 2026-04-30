vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO algebraic-solving/msolve
    REF "v${VERSION}"
    SHA512 e45fda8b8d7bcb4e443b5268875ddd5a9a88a65bf04b563d66b512500dec6508ad27c4ebfcba8a73868d20e92213d49dc8ac54cf3f00a326a3328901eb15c9b7
    HEAD_REF master
    PATCHES
        fix-android.patch
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
