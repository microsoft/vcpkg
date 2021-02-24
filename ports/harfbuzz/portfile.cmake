vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 7236c7e29cef1c2d76c7a284c5081ff4d3aa1127 # 2.7.4
    SHA512 d231a788ea4e52231d4c363c1eca76424cb82ed0952b5c24d0b082e88b3dddbda967e7fffe67fffdcb22c7ebfbf0ec923365eb4532be772f2e61fa7d29b51998
    HEAD_REF master
    PATCHES
        0002-fix-uwp-build.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    icu         icu
    graphite2   graphite
    glib        glib
)

string(REPLACE "=ON" "=enabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
string(REPLACE "=OFF" "=disabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
        -Dfreetype=enabled
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
