
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bbalouki/itchcpp
    REF "v${VERSION}"
    SHA512 d9fa43517070937d74b739083fd63e97379c28296ffc5f026173ddfd044b0f5d873264520d5d24022d29f25e48cc2389c5bff2d953407b617bcbfa27ede89592
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        arrow ITCH_WITH_ARROW
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
