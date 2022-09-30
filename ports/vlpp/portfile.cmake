vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 2526183a61d2791c744a22dc8967b474fa803c52 # 1.1.0.0
    SHA512 4bab19da5274f4ade656176f10f38dc4896a51ddb6828a6a419f084d32cac8352ef8814d928a8a252a4a963e09fdf451a558acfce23118a32ad6fb8580677c85
    HEAD_REF master
)

if ("tool" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH GACGEN_SOURCE_PATH
        REPO vczh-libraries/GacUI
        REF 24e525948b54a08ec2cd5075033e7b167084de3a
        SHA512 f8055c4f738de8a9f8c76d73e6ffd576c03e3f9c5c7a0c23cf0adb3128bb3f2cb7fb174bdbadee460d4e2833b9f7c29706101691dcb61e705d59e19fc5961e2f
        HEAD_REF master
    )
    vcpkg_from_github(
        OUT_SOURCE_PATH CPPMERGE_SOURCE_PATH
        REPO vczh-libraries/Workflow
        REF 72fcc5e120450874de259c1be2fdfd86bc656182
        SHA512 ec4429708a755430b37050a78bea915230cb7a2a0c64681313f6875b6ad1ef17867d72d2a009d531d6c8778621b5d93634eef7d53af3c19be414bd0e19b9d828
        HEAD_REF master
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
        LOGFILE_BASE "vlpp-gacgen"
    )
    vcpkg_cmake_install()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.cppmerge.txt" "${CPPMERGE_SOURCE_PATH}/CMakeLists.txt" COPYONLY)
    vcpkg_cmake_configure(
        SOURCE_PATH "${CPPMERGE_SOURCE_PATH}"
        LOGFILE_BASE "vlpp-cppmerge"
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
