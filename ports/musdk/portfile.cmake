vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MarvellEmbeddedProcessors/musdk-marvell
    REF "releasetag-musdk-release-SDK${VERSION}"
    SHA512 ef944ebe9098d2f495bee10dea250bfb990d0bbc9a2ac49aa62420e27e07d37276078c3e5456b082ab20e3cf5ebf756b5d13aca56b4db5ce4590378a1f2769d5
    HEAD_REF musdk-release
    PATCHES
        0001-disable-apps.patch
        0002-disable-warnings-as-errors.patch
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    COPY_SOURCE
    OPTIONS
        --enable-giu
        --enable-neta
        --enable-nmp
        --enable-pp2
        --enable-sam
)

vcpkg_make_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/license.txt"
    "${SOURCE_PATH}/LICENSE"
)
