vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Framstag/libosmscout
    REF c81e1d9a0f69cc5b93588dbe330b2af587162c5f
    SHA512 d6ddbc49dd40b1f938ae2cd1ea9342cab0a52db46bf7ed6716111a91d0a38acba12ff2e273d457db51fc240d578a5b849af77b53e600482cf52c3b22306f8c45
    HEAD_REF master
    PATCHES
        protobuf-linkage.patch
        fix-libxml2.patch
        msvc-arm.diff
        msvc-static.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cairo   OSMSCOUT_BUILD_MAP_CAIRO
        directx OSMSCOUT_BUILD_MAP_DIRECTX
        gdi     OSMSCOUT_BUILD_MAP_GDI
        qt5     OSMSCOUT_BUILD_MAP_QT
        svg     OSMSCOUT_BUILD_MAP_SVG
        tools   OSMSCOUT_BUILD_TOOL_IMPORT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOSMSCOUT_BUILD_DEMOS=OFF
        -DOSMSCOUT_BUILD_TOOL_DUMPDATA=OFF
        -DOSMSCOUT_BUILD_TOOL_OSMSCOUT2=OFF
        -DOSMSCOUT_BUILD_TOOL_OSMSCOUTOPENGL=OFF
        -DOSMSCOUT_BUILD_TOOL_PUBLICTRANSPORTMAP=OFF
        -DOSMSCOUT_BUILD_TOOL_STYLEEDITOR=OFF
        -DOSMSCOUT_BUILD_EXTERN_MATLAB=OFF
        -DOSMSCOUT_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DOSMSCOUT_BUILD_TOOL_IMPORT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/libosmscout)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES BasemapImport Import AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
