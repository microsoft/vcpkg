vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 039b6fcb5325af186060d2e6efb466f3d81afcb5 # 1.1.0.0
    SHA512 7c4da7f5686dd3ef8ddd211e440a9b70000fb5558a67fe75d73a3662ff6bd441fb0d2a125d77d9353abf0b5d273546d9fced9fba205a8aa4347a72e15064caf2
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
        REF 1de25738b534f78f7dce721798ff367099526488
        SHA512 adc104d22f9ce61e82f40875e217ec2cfcc32d3088cf8f32bca16ea99084bb62aaae1601ddea328ce2eb9ddb321db9779352cbccd9437e21e3210e32286feb85
        HEAD_REF master
    )
    vcpkg_from_github(
        OUT_SOURCE_PATH CPPMERGE_SOURCE_PATH
        REPO vczh-libraries/Workflow
        REF 3b1984b0d9e9602757774d259d11bdb43e5e30c4
        SHA512 dcb41d4658d65510d6ffc6015f79eb9d08cf6a7f52fc24b8832bfdc1706ea7d3dcef34bb46b4664b09579b4787bf01406b68a33193c8952a6e13018793ef05e8
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

vcpkg_cmake_config_fixup()

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
