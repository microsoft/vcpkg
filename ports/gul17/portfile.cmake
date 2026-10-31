vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gul-cpp/gul17
    REF "v${VERSION}"
    SHA512 26f79bc0c8a2ddb2f259f06cdf5f22622f6f33a11562a5bf1115a126a35e7c2b6fcd86e636a29d6cd3d35d1b91179d96e7dd1a6066e720cafd082c0162a7bcd3
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Install copyright file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
