vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 9c98b2b9a9e43669c5e2b37eaa41b1e07de1ede3 # 2.7.2
    SHA512 00b61034abce61370a7ff40bf5aa80bc1b3557d1f978ef91725fc30b34c4c00c682a3b9c99233e7e52d579b60694a1ba08714d5c9b01ad13e9fd76828facc720
    HEAD_REF master
    PATCHES
        0002-fix-uwp-build.patch
        icu.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    icu         icu
    graphite2   graphite
)

string(REPLACE "=ON" "=enabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
string(REPLACE "=OFF" "=disabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
        -Dfreetype=enabled
        -Dglib=disabled
        -Dgobject=disabled
        -Dcairo=disabled
        -Dfontconfig=disabled
        -Dintrospection=disabled
        -Ddocs=disabled
        -Dtests=disabled
        -Dbenchmark=disabled
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
configure_file("${CMAKE_CURRENT_LIST_DIR}/harfbuzzConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/harfbuzzConfig.cmake" @ONLY)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
