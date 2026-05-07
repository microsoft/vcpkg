vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lttng/lttng-ust
    REF "v${VERSION}"
    SHA512 23c2aba802fff0b2b87567536ecac2b72e3cae5089e50004bb45f0316558570a80eaf521a04911510eeaf9fe0e2017ff54f39ae3556543556e31f9a76db2e7b0
    HEAD_REF master
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --disable-man-pages
        --disable-examples
        --disable-numa
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
