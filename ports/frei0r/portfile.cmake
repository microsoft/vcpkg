# Frei0r dlls are MODULE librarys that are meant to be loaded at runtime,
# hence they don't have import libs
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dyne/frei0r
    REF "v${VERSION}"
    SHA512 46276108c252c2e10f290fe3854575e642968138e13ab3630ca3d0f2ec2af8af01b6fc579b73a904542bfd9e4fbfa1c6eb4fd643e82b7e475b992b6baa002fa6
    HEAD_REF master
    PATCHES
        001-fix-defs.patch
        002-install-dlls-to-bin.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        cairo   WITHOUT_CAIRO
        opencv  WITHOUT_OPENCV
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
      -DWITHOUT_GAVL=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
