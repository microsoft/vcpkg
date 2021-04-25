vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mixxxdj/libkeyfinder
    REF v2.2.4
    SHA512 6673b9a81dbfa3693fc4e7af4e5fc0f351f0c60b00fdafeb9e3437e2f77b5fec7d1e78e3989ff1daca72770a1d3cdbe3837508718b8e8aba3ac3f3d56af81a56
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    test BUILD_TESTING
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KeyFinder TARGET_PATH share/KeyFinder)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
