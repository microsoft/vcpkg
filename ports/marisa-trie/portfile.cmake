if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO s-yata/marisa-trie
    REF v${VERSION}
    SHA512 6d72b13daec877c9c42e2c93e591e3a5e9c738bb130c5d90d6adfde81d5b500684ca176439b7502d9243b6417f34c7b39750ff3fb3a5c52d8d06cb9bc5f14c22
    HEAD_REF master
    PATCHES
        enable-debug.patch
        fix-install.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        tools    ENABLE_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Marisa)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if ("tools" IN_LIST FEATURES)
    set(TOOL_NAMES marisa-benchmark marisa-build marisa-common-prefix-search marisa-dump marisa-lookup marisa-predictive-search marisa-reverse-lookup)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.md")
