vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/drogon
    REF v1.3.0
    SHA512 cddda4b90d28c15319b9cd1dea561c429b804508fc40678b9906fb70153cb36d7a4fc1c13fee01ec1f49d747a722856ceee364aba4118d922afabc3629ba2115
    HEAD_REF master
    PATCHES
        vcpkg.patch
        resolv.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    ctl BUILD_CTL
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

# Fix CMake files
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Drogon)
# Copy drogon_ctl
if("ctl" IN_LIST FEATURES)
    message("copying tools")
    vcpkg_copy_tools(TOOL_NAMES drogon_ctl
                     AUTO_CLEAN)
endif()
# # Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Copy pdb files
vcpkg_copy_pdbs()

