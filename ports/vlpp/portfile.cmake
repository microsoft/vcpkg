vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 471674f8050f8168d7de7d73cb2e84101bdf7b29 # 1.1.0.0
    SHA512 2b24e813626c390c88107db7d9253583f1eac4d091b46876973ac82b415be43d846c9c0965b4de8ea61b97da07a102055c36ed855878f446d0371555d6172b53
    HEAD_REF master
    PATCHES fix-tool-build.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH LICENSE_PATH
    REPO vczh-libraries/License
    REF 2173abd38478ba78f7a8f1a062475d04c014eb7a
    SHA512 fb8df2380640c3ca14fce1320cdfb47b002eabbe42fa2d1a5356b3c641138d61b8f79f9d4894573d759876d1ab18f822d7fac4e4bce5c14f449acda29aac5e9c
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        reflection          REFLECTION
        glrparser           GLR_PARSER
        workflowlibrary     WORKFLOW_LIBRARY
        workflowruntime     WORKFLOW_RUNTIME
        workflowcompiler    WORKFLOW_COMPILER
        gacuicore           GACUI_CORE
        gacuirecompiler     GACUI_COMPILER
        gacuireflection     GACUI_REFLECTION
        tools               BUILD_TOOLS
)

if (BUILD_TOOLS)
    vcpkg_from_github(
        OUT_SOURCE_PATH GACGEN_SOURCE_PATH
        REPO vczh-libraries/GacUI
        REF e2faa7e3d2935dfc5ec5b99ca22c2a266f24a314
        SHA512 14b9a3b12b694a37cfd499cc27927ca6df949bfed035a5a37b02ee09d267ef76f3e93242571f2921f2ec1074595a6bc7567664f5926272c14e16b79e5b544c2a
        HEAD_REF master
    )
    vcpkg_from_github(
        OUT_SOURCE_PATH CPPMERGE_SOURCE_PATH
        REPO vczh-libraries/Workflow
        REF e6340a43973f5663702b8c7424722a6c70af72c7
        SHA512 93f4fd36b3c41169ee9384eed3f4d4deaa371c0e7bf56653fcaff649f0a2993af129177ada1265a92b7f47ff387a545417528f156205c210cb907d3c6eeb6992
        HEAD_REF master
    )

    if (NOT EXISTS "${SOURCE_PATH}/Import/gacgen")
        file(RENAME "${GACGEN_SOURCE_PATH}" "${SOURCE_PATH}/Import/gacgen")
    endif()
    if (NOT EXISTS "${SOURCE_PATH}/Import/workflow")
        file(RENAME "${CPPMERGE_SOURCE_PATH}" "${SOURCE_PATH}/Import/workflow")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Import"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-vlpp)

if (BUILD_TOOLS)
    file(GLOB TOOL_GACGEN "${CURRENT_PACKAGES_DIR}/bin/GacGen*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    get_filename_component(TOOL_GACGEN "${TOOL_GACGEN}" NAME_WLE)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_GACGEN} CppMerge AUTO_CLEAN)

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
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${LICENSE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
