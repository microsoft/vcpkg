vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF "v${VERSION}"
    SHA512 ceed4fffc381bebd5456d56e8f9d84094da2a9994c8be60e9c1fe4a72ae5f2c398448169927af1439615b55c549332dfe4c38a2b3b8bdf84e3c550fd14bf125c
    HEAD_REF main
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/share/cmake")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/stlabConfig.cmake"
    "find_dependency(Boost 1.74.0)"
    "if(APPLE)\nfind_dependency(Boost)\nendif()"
)


file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
