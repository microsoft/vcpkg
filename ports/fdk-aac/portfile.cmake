vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    FEATURES
        he-aac HE_AAC
)

set(legal_notes "NOTICE")
if(HE_AAC)
    vcpkg_from_github(
        REPO mstorsjo/fdk-aac
        REF v2.0.2
        SHA512 616207e85035d1659a2b7808ca6ec02ef53c1c4b39eb280fe861f82a4cf548e5db2ac381c496bad37dfc2b8c6677fe704d9fd8449e43d1f93d3e636239e0191b
        HEAD_REF master
        OUT_SOURCE_PATH SOURCE_PATH
        PATCHES
            cxx-linkage-pkgconfig.patch
    )
else()
    list(PREPEND legal_notes "README.fedora")
    vcpkg_from_gitlab(
        GITLAB_URL https://gitlab.freedesktop.org/
        REPO wtaymans/fdk-aac-stripped
        REF 529b87452cd33d45e1d0a5066d20b64f10b38845 # corresponds to v2.0.2 tag in mstorsjo/fdk-aac GitHub repository
        HEAD_REF stripped4
        SHA512 0c37f8fd1bd0e817d2b3970138bef5b2a7a3150ab1a772273c8f5cba09be04afa2f31780f0ea063dd786a71844aa4cb5821349a4bcc5ebe70e827c3561eda2a9
        OUT_SOURCE_PATH SOURCE_PATH
        PATCHES
            cxx-linkage-pkgconfig.patch
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_PROGRAMS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

list(TRANSFORM legal_notes PREPEND "${SOURCE_PATH}/")
vcpkg_install_copyright(FILE_LIST ${legal_notes})
