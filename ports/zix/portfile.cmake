vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/zix
    REF "v${VERSION}"
    SHA512 17ee8e2dc5399e8bce87c5f625459a9784b96fb21e1020d689a9c5d7f4afa75871c531b1dfdf21e6b200d5cfdd648bac89d73af8cfef0569ad3cd14d0b6c5016
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbenchmarks=disabled
        -Ddocs=disabled
        -Dtests=disabled
        -Dtests_cpp=disabled
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
