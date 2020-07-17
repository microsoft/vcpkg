vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Cross
    REF b1082c10afe15eef03e8b12d66008388ce2a468c
    SHA512 56ecc559157237e54684862501b7697ea9a43996823361787209ddff8e18ee3fa1bb95bcfca19a371ff066882a177663d6d0d667d95a2c0cffc377d59dd6e5f6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

foreach(COMPONENT core cpp glsl hlsl msl reflect util)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/spirv_cross_${COMPONENT}/cmake TARGET_PATH share/spirv_cross_${COMPONENT})
endforeach()

vcpkg_copy_tools(
    TOOL_NAMES spirv-cross
    AUTO_CLEAN
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
