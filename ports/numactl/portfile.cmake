vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numactl/numactl
    REF "v${VERSION}"
    SHA512 a9aa93bdc6333b620c10ff3573d6ff645ab54beece75e67be8cdddb27d062cc56cea34db342005a171877f85f05eb1d24e43f8466be907ba3b7c8b1f897cd954
    HEAD_REF master
    PATCHES
        pkgconfig.diff
)

message(
"numactl currently requires the following libraries from the system package manager:
    autoconf libtool
These can be installed on Ubuntu systems via
    sudo apt install autoconf libtool"
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md" "${SOURCE_PATH}/LICENSE.LGPL2.1" "${SOURCE_PATH}/LICENSE.GPL2")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" ".*# License" "# License" REGEX)
