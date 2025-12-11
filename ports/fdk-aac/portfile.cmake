vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    FEATURES
        he-aac HE_AAC
)

set(legal_notes "NOTICE")
if(HE_AAC)
    vcpkg_from_github(
        REPO mstorsjo/fdk-aac
        REF "v${VERSION}"
        SHA512 f8ea7abe83e6e138dac4a06f195bdf870bca93137bdaea6f5d85f266f3659b4a1b54da3b4c02a1eba3a134d9d19dcf89908cfbed4bbcab8550e114e84c333779
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
        REF 9896ddc0d08bb3f764f01d5e372bec1c068ad8f5 # corresponds to v2.0.3 tag in mstorsjo/fdk-aac GitHub repository
        HEAD_REF stripped5
        SHA512 af19608d54a32a153f8b11f7a92d6c41f0eab890426fa03aad0a68961402ebc6a85f97fae2d64bdfa25c3ba4553eaafab78abfbaf8542291c48bbba9333d8e9b
        OUT_SOURCE_PATH SOURCE_PATH
        PATCHES
            cxx-linkage-pkgconfig.patch
            cmake_fix.patch # Some files were removed in 2fc6d97f7881816969caab88015688ecb0cea7d0, but CMakeFile adjustment was incomplete
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
