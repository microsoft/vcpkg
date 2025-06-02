if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-iceoryx/iceoryx
    REF "v${VERSION}"
    SHA512 708c113f8b4e5a23830172cd67414cb6fa389f9bc34a5979b27131c3180d6758ca50257baa86cb6f74bcff71b24237cffc0e697964a7c0326e9018fbf7885c09
    HEAD_REF master
    PATCHES
        acl.patch
        add-include-chrono.patch # https://github.com/eclipse-iceoryx/iceoryx/pull/2378
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
