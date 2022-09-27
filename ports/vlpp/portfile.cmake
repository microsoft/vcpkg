vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 0a7bf9b4f7e705f17efc2ada5aa2b089147234d4 # 1.1.0.0
    SHA512 b70081495f2843a45ea2aea37a2d00327e336a3313acfa20421de4748c880905279353c03ecc50f45e9cda0aae34aad69ba44de81fa2fd4d4855be6002dd068f
    HEAD_REF master
    PATCHES fix-arm.patch
)

if ("tool" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH GACGEN_SOURCE_PATH
        REPO vczh-libraries/GacUI
        REF 83501365b241fb77b6c08693a001bf16510dcb8c
        SHA512 db51341647139fec133ae19c122bd1ee3a4d07ddb822a7c156d24f2960279bfd6dd87b20a9d60fe1c2ce43c5dc8188830aea58c08a7382bc69fc0f3bed86524a
        HEAD_REF master
        PATCHES fix-arm.patch
    )
    vcpkg_from_github(
        OUT_SOURCE_PATH CPPMERGE_SOURCE_PATH
        REPO vczh-libraries/Workflow
        REF 8bce9694692ba0da93a10d29224943656b02e573
        SHA512 ee17e2a99c78a5abb62708719989e9ae224bcec7a78cb08882870d0e21f2017d24d02c1c4c75d0ac89549478d49679681b3d11d76f408988306c85b1d3ab28ae
        HEAD_REF master
        PATCHES fix-arm.patch
    )
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

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
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSKIP_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-vlpp)

if ("tool" IN_LIST FEATURES)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.gacgen.txt" "${GACGEN_SOURCE_PATH}/CMakeLists.txt" COPYONLY)
    vcpkg_cmake_configure(
        SOURCE_PATH "${GACGEN_SOURCE_PATH}"
    )
    vcpkg_cmake_install()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.cppmerge.txt" "${CPPMERGE_SOURCE_PATH}/CMakeLists.txt" COPYONLY)
    vcpkg_cmake_configure(
        SOURCE_PATH "${CPPMERGE_SOURCE_PATH}"
    )
    vcpkg_cmake_install()
    
    vcpkg_copy_tools(TOOL_NAMES GacGen CppMerge AUTO_CLEAN)

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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
