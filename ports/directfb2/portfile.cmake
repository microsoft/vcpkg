vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO directfb2/DirectFB2
    REF "7d4682d0cc092ed2f28c903175d1a0c104e9e9a8" # no release tag available yet in upstream: https://github.com/directfb2/DirectFB2/issues/162
    SHA512 b57c43559992fc7594ca2806dd07c547c13260e7286791eadf64ec75631cb7d61d049d17644e714702919aaee82850387d08fc92b97b8a8a595981faf0c8f4a5
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_clean_executables_in_bin(FILE_NAMES dfb-update-pkgconfig)
