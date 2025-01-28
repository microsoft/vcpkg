vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linux-audit/audit-userspace
    SHA512 558b9211a5dc1062eee98aa7bcd292797f06109a8ee735da1d704bc18d97b0bee93487ef9303404016df2e08cff32d90f1dd056797ac05beaabe3cccb5db5af2
    REF "v${VERSION}"
    HEAD_REF master
    PATCHES
        fix-multiple-def.patch
)

message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n"
    "\t- <autoconf>\n"
    "\t- <automake>\n"
    "\t- <libtool>\n\n"
    "It can be installed with your package manager"
)

file(TOUCH "${SOURCE_PATH}/README")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --with-python3=no
        --with-golang=no
        --with-io_uring=no
        --with-warn=no
        --disable-zos-remote
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
