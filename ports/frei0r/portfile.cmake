# Frei0r dlls are MODULE librarys that are meant to be loaded at runtime,
# hence they don't have import libs
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dyne/frei0r
    REF "v${VERSION}"
    SHA512 f73723a165ac42029801b895d2324ee8dcf4d9b49165458e707b6891ad88294203848d2b1cd89ffe58769f13232f9175e17040fc30905b37df29d348c36f2e1c
    HEAD_REF master
    PATCHES
        001-fix-defs.patch
        002-install-dlls-to-bin.patch
        m_pi.patch
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
        -DBUILD_TESTING=OFF
        -DWITHOUT_GAVL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
)
