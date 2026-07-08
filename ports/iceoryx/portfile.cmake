if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-iceoryx/iceoryx
    REF "v${VERSION}"
    SHA512 e42558948f7c2eda3c17f9d6756aa60dba3e6009cbe7b8a8c7b1d66b71f43594c8a3c0543867cb496c25683950a8e1e5ec9e557644550394899293a621233ab4
    HEAD_REF master
    PATCHES
        acl.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "toml-config"       TOML_CONFIG
    INVERTED_FEATURES
        "many-to-many"      ONE_TO_MANY_ONLY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/iceoryx_meta"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DDOWNLOAD_TOML_LIB=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME iceoryx_binding_c CONFIG_PATH lib/cmake/iceoryx_binding_c DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME iceoryx_hoofs CONFIG_PATH lib/cmake/iceoryx_hoofs DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME iceoryx_posh CONFIG_PATH lib/cmake/iceoryx_posh)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

if(TOML_CONFIG)
    vcpkg_copy_tools(TOOL_NAMES iox-roudi AUTO_CLEAN)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
