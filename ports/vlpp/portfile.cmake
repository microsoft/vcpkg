vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 0a7bf9b4f7e705f17efc2ada5aa2b089147234d4 # 1.1.0.0
    SHA512 b70081495f2843a45ea2aea37a2d00327e336a3313acfa20421de4748c880905279353c03ecc50f45e9cda0aae34aad69ba44de81fa2fd4d4855be6002dd068f
    HEAD_REF master
    PATCHES fix-arm.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        workflowlibrary     WORKFLOW_LIBRARY
        workflowruntime     WORKFLOW_RUNTIME
        workflowcompiler    WORKFLOW_COMPILER
        gacui               GACUI
        darkskin            DARK_SKIN
        reflection          REFLECTION
        tool                BUILD_GACUI_COMPILER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSKIP_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-vlpp)

if (BUILD_GACUI_COMPILER)
    vcpkg_copy_tools(TOOL_NAMES GacGen)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Tools
file(INSTALL "${SOURCE_PATH}/Tools/CppMerge.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
