vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vpetrigo/smf
    REF v0.1.1
    SHA512 56e06ebcaa84beae2c65ab508b0b331a8c473600e91fcb797b413b774da0bbc7e2e44b93af810d739158a6ccf157f6ca32ba52efc8e47c366f94dec892623aa3
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hierarchical    SMF_ANCESTOR_SUPPORT
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
