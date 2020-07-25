vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 9c98b2b9a9e43669c5e2b37eaa41b1e07de1ede3 # 2.7.2
    SHA512 00b61034abce61370a7ff40bf5aa80bc1b3557d1f978ef91725fc30b34c4c00c682a3b9c99233e7e52d579b60694a1ba08714d5c9b01ad13e9fd76828facc720
    HEAD_REF master
    PATCHES
        0002-fix-uwp-build.patch
        # This patch is required for propagating the full list of dependencies from glib
        glib-cmake.patch
        fix_include.patch
        icu.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    icu         icu
    graphite2   graphite
    glib        glib
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS # ${FEATURE_OPTIONS}
        -Dglib=disabled
        -Dgobject=disabled
        -Ddocs=disabled
        -Dtests=disabled
        --backend=ninja
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
