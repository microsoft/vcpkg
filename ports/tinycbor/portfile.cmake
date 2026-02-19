vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/tinycbor
    REF "v${VERSION}"
    SHA512 193f995ecf1098accd04add3271aae834fd08aba94b7360ed0c22f8cc52d212cfe9c708c3cd89accaa27448078e95ae847ae91da661ca2cc4a1029e73b250b57
    HEAD_REF master
    PATCHES
        import-target-cjson.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS feature_options
    FEATURES
        tools           BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${feature_options}
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/tinycbor")
vcpkg_fixup_pkgconfig()

# Remove duplicated include headers
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            json2cbor
        AUTO_CLEAN
    )
    if (NOT WIN32)
        vcpkg_copy_tools(
            TOOL_NAMES
                cbordump
            AUTO_CLEAN
        )
    endif()
endif ()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
