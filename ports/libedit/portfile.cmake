message(
"libedit currently requires the following programs from the system package manager:
    autoconf autoheader aclocal automake libtoolize
On Debian and Ubuntu derivatives:
    sudo apt install autoconf libtool
On recent Red Hat and Fedora derivatives:
    sudo dnf install autoconf libtool
On Arch Linux and derivatives:
    sudo pacman -S autoconf automake libtool
On Alpine:
    apk add autoconf automake libtool"
)

string(REPLACE "-" "" REF_SHORT_VERSION_DATE ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://thrysoee.dk/editline/libedit-${REF_SHORT_VERSION_DATE}-3.1.tar.gz"
    FILENAME "libedit-${REF_SHORT_VERSION_DATE}-3.1.tar.gz"
    SHA512 b11d64947f9484bb2320b0fbcfdc94466993af1dfa0d853853b73c222e95d6c1e78d88d0c305929b95bf7a85009129475c9fef0ac8595b43d75543d85052a4ff
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)
vcpkg_install_make()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
