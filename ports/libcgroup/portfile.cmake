vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcgroup/libcgroup
    SHA512 53a1362de915a4d57573342234d72d8fe2d91a5df9e06835594235bca29027c10a1f0b232449aa75e1ee77bfd426e9bb11ea38ef001e1f541379d3eb07f94771
    REF "v${VERSION}"
    HEAD_REF master
)

message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n"
    "\t- <autoconf>\n"
    "\t- <automake>\n"
    "\t- <libtool>\n\n"
    "It can be installed with your package manager"
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --enable-tools=no
        --enable-python=no
        --enable-tests=no
        --enable-samples=no
        --enable-systemd=no
        --enable-pam=no
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
