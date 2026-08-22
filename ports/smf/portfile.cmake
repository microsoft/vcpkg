vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vpetrigo/smf
    REF "v${VERSION}"
    SHA512 bed114b54142e6fbcbb5eec9dc202c61f73e7592559eaaeb0ed3c62231ed1e4bd5eedf4ac5b5bfa2b4cf64095f432d09a8644c37b47cdba8c367b14ad080bba0
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
