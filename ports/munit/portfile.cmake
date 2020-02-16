vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemequ/munit
    REF 439de4a9b136bc3b5163e73d4caf37c590bef875
    SHA512 28fbe29636fd3ecb675f2e823165ac88be10adfbb2d4155fee43a4b2747c8dd4f24808ed9ddedd9a2ec60d96367e60fce8ca82c54b0eb605ed9b4bb05392a872
    HEAD_REF master
    PATCHES
        fix-install.patch
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --backend=ninja
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
