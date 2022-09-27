vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF d0630ae6461f890ac0a0fa09edd263c3f5abb10c # 1.1.0.0
    SHA512 8da6af0f6b283cff0f6dc38c36c4ea789a58dfa8c298557d9ecb0b7b423d4e5876ceeb1d16dccbf4b8da4a0f4adccbd1e89119b75dbb361bd2b4f092fda93c39
    HEAD_REF master
)

if ("tool" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH GACGEN_SOURCE_PATH
        REPO vczh-libraries/GacUI
        REF ea3bfe53ecb15861af8433d5ffc3d89a619830c1
        SHA512 bce8d767b2b02c6743892acd8b64dcd98c8d468d40d04c2af598b0cccb6d6a497a9424155ba7b153bb88c310541b3a26406f6f91b7265e6476033f09b736a7c1
        HEAD_REF master
    )
    vcpkg_from_github(
        OUT_SOURCE_PATH CPPMERGE_SOURCE_PATH
        REPO vczh-libraries/Workflow
        REF 2235f913c6ed112c8019c6115a11734eb63899b6
        SHA512 87da1ab837f6653de4394ff1f5e1800d0a457c728be93a414a1b7def392c5866792cb75aa0aef118565340c287e2b084a439592aea603b7967e3b3488e519006
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
