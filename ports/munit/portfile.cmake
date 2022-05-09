vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemequ/munit
    REF da8f73412998e4f1adf1100dc187533a51af77fd
    SHA512 cd08c1291a73487f15fdba7bf8675fea9177f0ec9766900f65efb5f00c662532a16499447e9087d304de34ff9138f47d04ebf18713f5aa8aacede22c5e23b98b
    HEAD_REF master
    PATCHES
        fix-install.patch
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
