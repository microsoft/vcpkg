vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lttng/lttng-ust
    REF "v${VERSION}"
    SHA512 543c76bebc7a93368f14d427a545ecb455eba7fd4bf037a96109414362033ebae247684f2c83ef8588a12ca759fdf970f930dfdf640b4bd6a41514b40ea78b86
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
