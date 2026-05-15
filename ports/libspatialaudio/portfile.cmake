vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/libspatialaudio
    REF "${VERSION}"
    SHA512 80125610be6d9881bf49b72373d28931a1cd475d2eda1c6357db9c7fc959b674b30dc80afee4e33255ceb516d1d66d9f216f835d589e215aeed90d5dbbbc9699
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dlibmysofa=disabled
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
