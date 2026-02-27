# Frei0r dlls are MODULE librarys that are meant to be loaded at runtime,
# hence they don't have import libs
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

vcpkg_download_distfile(FIX_UPSTREAM_PR_252
    URLS https://github.com/dyne/frei0r/pull/252.patch?full_index=1
    SHA512 bdf8c6e64d73495a843c76d08204217002f1108363674633a70574ba05f0f33efafc567b73f604c7c76fd9a9614a64ccadd62c3709454b52efbb8b8d61055532
    FILENAME fix-sleid0r-symbol-export.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dyne/frei0r
    REF "v${VERSION}"
    SHA512 81831ede1d76d0ad8811f6b8116eb71a74e5af47a3249954f2c6f327e71e618d92c31f19566963bd9952363b22c5a6606df3ef8592f97c3bb1cd8ed9abe94c14
    HEAD_REF master
    PATCHES
        "${FIX_UPSTREAM_PR_252}"
        install-dlls-to-bin.diff
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
