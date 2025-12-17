vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/zix
    REF "v${VERSION}"
    SHA512 dd3073c9740ddb3a476b51977e80343fe668b4957db20c134c5ba22d10fe64de9cc2fa53aa6059f61ad010ef9fa967f36e178bc789f4073c736a7897b1f81345
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
