vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF "v${VERSION}"
    SHA512 343eeb970374d3ff989d9e688f4971b717f2e20b6d6fe1a4a1754484b4b7330075cb94e427d972d936fc8dc4650b1f00ca63d72981fb2d21373c1733b56fd124
    HEAD_REF main
    PATCHES
        cross-build.patch
        devendoring.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpp17shims   STLAB_USE_BOOST_CPP17_SHIMS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/stlab)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/stlabConfig.cmake"
    "find_dependency(Boost 1.74.0)"
    "if(APPLE)\nfind_dependency(Boost)\nendif()"
)


file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
