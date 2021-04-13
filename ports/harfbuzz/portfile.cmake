vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 03538e872a0610a65fad692b33d3646f387cf578 # 2.8.0
    SHA512 3d9d2804776ce01cf3fe1fe789c584f59cb9f4f57312fac50e195cb455936613d96f0c1920d0e09217c8fb5cbb4ba4f366cb1ff8ff0643a7f8a68f2a1c3d2a3d
    HEAD_REF master
    PATCHES
		# This patch is a workaround that is needed until the following issues are resolved upstream:
		# - https://github.com/mesonbuild/meson/issues/8375
		# - https://github.com/harfbuzz/harfbuzz/issues/2870
		# Details: https://github.com/microsoft/vcpkg/issues/16262
		0001-circumvent-samefile-error.patch
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
