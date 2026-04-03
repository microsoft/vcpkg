# Frei0r dlls are MODULE librarys that are meant to be loaded at runtime,
# hence they don't have import libs
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dyne/frei0r
    REF "v${VERSION}"
    SHA512 323028431039a14947234ec2ce969d2fd3121fda47d3ac57e7cfb9ddc12c4c6545824e8fed0efb6860beb14983fd3a1879a85879aed4a6655d9608ea6a85f971
    HEAD_REF master
    PATCHES
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
