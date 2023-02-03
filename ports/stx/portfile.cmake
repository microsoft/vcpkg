vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lamarrr/STX
    REF v1.0.1
    SHA512 544ca32f07cd863082fa9688f5d56e2715b0129ff90d2a8533cc24a92c943e5848c4b2b06a71f54c12668f6e89e9e3c649f595f9eb886f671a5fa18d343f794b
    HEAD_REF master
    PATCHES
        "CMakeLists.patch"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
     backtrace    STX_ENABLE_BACKTRACE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSTX_BUILD_DOCS=OFF
        -DSTX_BUILD_BENCHMARKS=OFF
        -DSTX_BUILD_SHARED=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/stx)
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)
