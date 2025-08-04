vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/VbsEnclaveTooling
    REF "codegen-v${VERSION}"
    SHA512 "cd8684540c053172fcdc2433f7c11e71706f031b92d776c2c3ba9fd1a08f41e9c3475966666801261deb4de69b4a3a8306170c0d53ae97c40d6074768da429f8"
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

vcpkg_msbuild_install(
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_SUBPATH VbsEnclaveTooling.sln
  NO_INSTALL # Make sure libs, exes and dlls from consumed nuget packages don't get added
  NO_TOOLCHAIN_PROPS 
  OPTIONS 
    "/p:VbsEnclaveCodegenVersion=${VERSION}"
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

# veil_enclave_cpp_support lib contains CRT stubs and should not be autolinked globally to avoid symbol conflicts.
set(ENCLAVE_CPP_SUPPORT_DIR "${CURRENT_PACKAGES_DIR}/lib/manual-link")
set(ENCLAVE_CPP_SUPPORT_DEBUG_DIR "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")

# Note: the vcxproj project that creates edlcodegen.exe is always built using x64, regardless of what 
# is passed to vcpkg_msbuild_install. This is by design.
if (EXISTS "${RELEASE_BUILD_DIR}")
    vcpkg_copy_tools(TOOL_NAMES edlcodegen SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/_build/x64/Release"  AUTO_CLEAN)
    file(GLOB CPP_SUPPORT_LIB_FILE "${RELEASE_BUILD_DIR}/veil_enclave_cpp_support_${VCPKG_TARGET_ARCHITECTURE}_Release_lib.lib")
    file(MAKE_DIRECTORY "${ENCLAVE_CPP_SUPPORT_DIR}")
    file(INSTALL DESTINATION "${ENCLAVE_CPP_SUPPORT_DIR}" TYPE FILE FILES "${CPP_SUPPORT_LIB_FILE}")
endif()

if(EXISTS "${DEBUG_BUILD_DIR}")
    vcpkg_copy_tools(
        TOOL_NAMES edlcodegen 
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/_build/x64/Debug" 
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
        AUTO_CLEAN
    )

    file(GLOB CPP_SUPPORT_LIB_FILE "${DEBUG_BUILD_DIR}/veil_enclave_cpp_support_${VCPKG_TARGET_ARCHITECTURE}_Debug_lib.lib")
    file(MAKE_DIRECTORY "${ENCLAVE_CPP_SUPPORT_DEBUG_DIR}")
    file(INSTALL DESTINATION "${ENCLAVE_CPP_SUPPORT_DEBUG_DIR}" TYPE FILE FILES "${CPP_SUPPORT_LIB_FILE}")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")