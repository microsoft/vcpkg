set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

find_program(pwsh_exe NAMES pwsh powershell)

set(subdir "compiler/msvc/")
set(vs_base_dir "${CURRENT_PACKAGES_DIR}/${subdir}VS")
set(installFolderSdk "${CURRENT_PACKAGES_DIR}/${subdir}WinSDK")

include("${CMAKE_CURRENT_LIST_DIR}/portfile_winsdk.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/portfile_toolkit.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/portfile_msbuild.cmake")

if(NOT VCPKG_CRT_LINKAGE STREQUAL "static")
    file(COPY "${vs_base_dir}/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}/x64/Microsoft.VC143.CRT/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY "${vs_base_dir}/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}/x64/Microsoft.VC143.MFC/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY "${installFolderSdk}/Windows Kits/10/Redist/${WinSDK_VERSION}/ucrt/DLLs/x64/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

    if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${vs_base_dir}/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}/debug_nonredist/x64/Microsoft.VC143.DebugCRT/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY "${vs_base_dir}/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}/debug_nonredist/x64/Microsoft.VC143.DebugMFC/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY "${installFolderSdk}/Windows Kits/10/bin/${WinSDK_VERSION}/x64/ucrt" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY "${installFolderSdk}/Windows Kits/10/Redist/${WinSDK_VERSION}/ucrt/DLLs/x64/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin" PATTERN "ucrtbase.dll" EXCLUDE)
    endif()
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/msvc-env.cmake" "${CURRENT_PACKAGES_DIR}/env-setup/msvc-env.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/msvc-env.ps1" "${CURRENT_PACKAGES_DIR}/env-setup/msvc-env.ps1" @ONLY)