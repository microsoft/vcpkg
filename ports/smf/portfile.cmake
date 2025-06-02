vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vpetrigo/smf
    REF "v${VERSION}"
    SHA512 afe1b8e670c06f9ba50a8338957d2a23fc0ccda9a22a8091bc58b4ed3b6714907a85b8f6a823cde6eff1dfcbb5a834f31c5d14559ebbf92a73576f932c4e311d
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
