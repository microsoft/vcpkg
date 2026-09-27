
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bbalouki/itchcpp
    REF "v${VERSION}"
    SHA512 81ebc631a6a1d23b903a8726354f3abce1f76050521e031025b5cd7a9ebd055f0fbf84b8686978edc7aabbcaeb5458e2c621c17fa26147828f3a7b31f8d9eeef
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        arrow ITCH_WITH_ARROW
        python ITCH_BUILD_PYTHON
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DITCH_BUILD_TESTS=OFF
        -DITCH_BUILD_BENCHMARKS=OFF
        -DITCH_BUILD_EXAMPLES=OFF
        -DITCH_PROJECT_ENV=PROD
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "itch"
    CONFIG_PATH "lib/cmake/itch"
   
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
