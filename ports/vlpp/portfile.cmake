vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 0a7bf9b4f7e705f17efc2ada5aa2b089147234d4 # 1.1.0.0
    SHA512 b70081495f2843a45ea2aea37a2d00327e336a3313acfa20421de4748c880905279353c03ecc50f45e9cda0aae34aad69ba44de81fa2fd4d4855be6002dd068f
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        reflection          REFLECTION
        glrparser           GLR_PARSER
        workflowlibrary     WORKFLOW_LIBRARY
        workflowruntime     WORKFLOW_RUNTIME
        workflowcompiler    WORKFLOW_COMPILER
        gacuicore           GACUI
        gacuirecompiler     GACUI_COMPILER
        gacuireflection     GACUI_REFLECTION
)

if ("tool" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH GACGEN_SOURCE_PATH
        REPO vczh-libraries/GacUI
        REF 83501365b241fb77b6c08693a001bf16510dcb8c
        SHA512 b70081495f2843a45ea2aea37a2d00327e336a3313acfa20421de4748c880905279353c03ecc50f45e9cda0aae34aad69ba44de81fa2fd4d4855be6002dd068f
        HEAD_REF master
    )
    vcpkg_from_github(
        OUT_SOURCE_PATH CPPMERGE_SOURCE_PATH
        REPO vczh-libraries/Workflow
        REF 8bce9694692ba0da93a10d29224943656b02e573
        SHA512 b70081495f2843a45ea2aea37a2d00327e336a3313acfa20421de4748c880905279353c03ecc50f45e9cda0aae34aad69ba44de81fa2fd4d4855be6002dd068f
        HEAD_REF master
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSKIP_HEADERS=ON
)

vcpkg_cmake_install()

if ("tool" IN_LIST FEATURES)
    vcpkg_install_msbuild(
        SOURCE_PATH ${CPPMERGE_SOURCE_PATH}
        PROJECT_SUBPATH Tools/GacGen/GacGen/GacGen.vcxproj
    )
    
    vcpkg_install_msbuild(
        SOURCE_PATH ${GACGEN_SOURCE_PATH}
        PROJECT_SUBPATH Tools/CppMerge/CppMerge/CppMerge.vcxproj
    )
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-vlpp)

if ("tool" IN_LIST FEATURES)
    # Handle scripts
    if (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
        set(TOOL_SCRIPT_SUFFIX ".ps1")
    else()
        set(TOOL_SCRIPT_SUFFIX ".bin")
    endif()
    file(GLOB TOOL_SCRIPTS "${SOURCE_PATH}/Tools/*${TOOL_SCRIPT_SUFFIX}")
    foreach (TOOL_SCRIPT IN LISTS TOOL_SCRIPTS)
        file(COPY "${TOOL_SCRIPT}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endforeach()
    # Handle tools
    vcpkg_copy_tools(TOOL_NAMES GacGen CppMerge AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
