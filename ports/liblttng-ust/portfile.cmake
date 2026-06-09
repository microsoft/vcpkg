vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lttng/lttng-ust
    REF "v${VERSION}"
    SHA512 7892156ba81542e2a0c3ca584a1f28c69e74280bd977c7829de160ce6555926b9a8631804e3631c30542343167fb1065d22840a0194760f5e92e8f998adf48b0
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
