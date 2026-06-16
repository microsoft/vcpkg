vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO algebraic-solving/msolve
    REF "v${VERSION}"
    SHA512 d51e63aa411a6d532812b725d39d546b58e0198aaf5e5ccf7796d616438edd280c340db735c5330bbc8aa2acdfe354f34c64ac7663f1c0014cf1f483e09aab35
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
