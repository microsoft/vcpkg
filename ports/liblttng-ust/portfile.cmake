vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lttng/lttng-ust
    REF "v${VERSION}"
    SHA512 0
    HEAD_REF master
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)

vcpkg_make_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
