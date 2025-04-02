vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vpetrigo/smf
    REF "v${VERSION}"
    SHA512 177eca0cfe3120e5dabe70695c78f9035255e7f07f9722783b269a2531573d6a3357c5a807800b7b61448e6aa7cbdd996980662b71cd23711b78cc2ce892f64d
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hierarchical    SMF_ANCESTOR_SUPPORT
        init-transition SMF_INITIAL_TRANSITION
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "${FEATURE_OPTIONS}"
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/smf)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
