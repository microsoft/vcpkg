vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    FEATURES
        he-aac HE_AAC
)

if(HE_AAC)
    vcpkg_from_github(
        REPO mstorsjo/fdk-aac
        REF v2.0.2
        SHA512 616207e85035d1659a2b7808ca6ec02ef53c1c4b39eb280fe861f82a4cf548e5db2ac381c496bad37dfc2b8c6677fe704d9fd8449e43d1f93d3e636239e0191b
        HEAD_REF master
        OUT_SOURCE_PATH SOURCE_PATH
    )
else()
    vcpkg_from_gitlab(
        GITLAB_URL https://gitlab.freedesktop.org/
        REPO wtaymans/fdk-aac-stripped
        REF 585981a49f2186b0d2e47c64bf6b5abf539395f8 # corresponds to v2.0.2 tag in mstorsjo/fdk-aac GitHub repository
        HEAD_REF stripped4
        SHA512 e0e56396ed0be427302ed4b54fc6e8dc522a172c288b7c1ec40cc3a9ceb13518ca7bbb874bc71b88b2a91e0bbbe4ad0bab6910efa1db63d91e6370976641bac4
        OUT_SOURCE_PATH SOURCE_PATH
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_RELEASE -DBUILD_PROGRAMS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/NOTICE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
