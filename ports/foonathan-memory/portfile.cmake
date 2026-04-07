vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/memory
    REF "v0.7-4"
    SHA512 fe6d429644c3e5edfb5666e4047ece45766fa5907094903cbd1e5b91e164fa31b7596ea5627e0272cbb8ea0a2b26a1f57564c797874718396ea87d8fad7ab559
    HEAD_REF master
    PATCHES
        config-debug.diff
        backport-0f5ebe9f.diff # Fix deprecated literal operator syntax
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    tool FOONATHAN_MEMORY_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFOONATHAN_MEMORY_BUILD_EXAMPLES=OFF
        -DFOONATHAN_MEMORY_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DFOONATHAN_MEMORY_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH share/foonathan_memory/cmake PACKAGE_NAME foonathan_memory)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/foonathan_memory/cmake PACKAGE_NAME foonathan_memory)
endif()

vcpkg_copy_pdbs()

if(NOT VCPKG_BUILD_TYPE)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/include/foonathan/memory/config_impl.hpp" "${CURRENT_PACKAGES_DIR}/include/foonathan/memory/config_impl-debug.hpp")
    file(RENAME "${CURRENT_PACKAGES_DIR}/include/foonathan/memory/config_impl.hpp" "${CURRENT_PACKAGES_DIR}/include/foonathan/memory/config_impl-release.hpp")
    file(COPY_FILE "${CURRENT_PORT_DIR}/config_impl.hpp" "${CURRENT_PACKAGES_DIR}/include/foonathan/memory/config_impl.hpp")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/foonathan_memory"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/LICENSE"
    "${CURRENT_PACKAGES_DIR}/debug/README.md"
    "${CURRENT_PACKAGES_DIR}/lib/foonathan_memory"
    "${CURRENT_PACKAGES_DIR}/LICENSE"
    "${CURRENT_PACKAGES_DIR}/README.md"
)

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES nodesize_dbg AUTO_CLEAN)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
