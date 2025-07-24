vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/VbsEnclaveTooling
    REF "v${VERSION}"
    SHA512 "510638e1b29125ed65423de03c5b8c57c27811832e0ebb60942c1d4b97a91be934c9a63b5550a52e9e2ac0a19fa5674f78f9d86e1393081c0042748934fdcd2b"
    HEAD_REF main
)

# All the projects in the repo require some nuget packages to be installed so we need
# to run nuget restore prior to running the msbuild function.
vcpkg_find_acquire_program(NUGET)
vcpkg_execute_required_process(
    COMMAND ${NUGET} restore "${SOURCE_PATH}/VbsEnclaveTooling.sln"
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME nuget-restore
)

vcpkg_list(SET MSBUILD_OPTIONS
    "/p:VbsEnclaveCodegenVersion=${VERSION}"
)

vcpkg_msbuild_install(
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_SUBPATH VbsEnclaveTooling.sln
  NO_INSTALL # Make sure libs, exes and dlls from consumed nuget packages don't get added
  NO_TOOLCHAIN_PROPS 
  OPTIONS 
    ${MSBUILD_OPTIONS}
)

file(INSTALL
    "${SOURCE_PATH}/src/ToolingSharedLibrary/Includes/VbsEnclaveABI"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    FILES_MATCHING PATTERN "*.h"
)

file(INSTALL
    "${SOURCE_PATH}/Common/veil_enclave_wil_inc/wil"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    FILES_MATCHING PATTERN "*.h"
)

set(RELEASE_BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/_build/${VCPKG_TARGET_ARCHITECTURE}/Release")
set(DEBUG_BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/_build/${VCPKG_TARGET_ARCHITECTURE}/Debug")

# Note: the vcxproj project that creates edlcodegen.exe is always built using x64, regardless of what 
# is passed to vcpkg_msbuild_install. This is by design.
if (EXISTS "${RELEASE_BUILD_DIR}")
    vcpkg_copy_tools(TOOL_NAMES edlcodegen SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/_build/x64/Release"  AUTO_CLEAN)
    file(GLOB CPP_SUPPORT_LIB_FILE "${RELEASE_BUILD_DIR}/veil_enclave_cpp_support_${VCPKG_TARGET_ARCHITECTURE}_Release_lib.lib")
    file(INSTALL DESTINATION "${CURRENT_PACKAGES_DIR}/lib" TYPE FILE FILES "${CPP_SUPPORT_LIB_FILE}")
endif()

if(EXISTS "${DEBUG_BUILD_DIR}")
    vcpkg_copy_tools(
        TOOL_NAMES edlcodegen 
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/_build/x64/Debug" 
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
        AUTO_CLEAN
    )

    file(GLOB CPP_SUPPORT_LIB_FILE "${DEBUG_BUILD_DIR}/veil_enclave_cpp_support_${VCPKG_TARGET_ARCHITECTURE}_Debug_lib.lib")
    file(INSTALL DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" TYPE FILE FILES "${CPP_SUPPORT_LIB_FILE}")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")