vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO algebraic-solving/msolve
    REF "v${VERSION}"
    SHA512 db6fdae0fafe785618e457c6db787e5b835b5487359fd72fc39ebfa7f64fcae63ea131a2e6fe9f832c64d549c454688306e25ba52a9f2c3fa14a50fabd31b0de
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
