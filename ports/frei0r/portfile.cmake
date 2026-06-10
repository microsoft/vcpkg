# Frei0r dlls are MODULE librarys that are meant to be loaded at runtime,
# hence they don't have import libs
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dyne/frei0r
    REF "v${VERSION}"
    SHA512 bbc894cad88c1927dfe8968f9708ad6c2715cefff7da949fb35db8dcde76ab7289907ad5181894dd4da5b57ec7a4f11923c5d8882de6578ea94c4d5d57f50153
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
