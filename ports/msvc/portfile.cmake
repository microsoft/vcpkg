set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
#set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)

find_program(pwsh_exe NAMES pwsh powershell)

set(WinSDK_VERSION "10.0.26100.0")
set(VCToolkit_VERSION "14.41.34120")
set(VCToolkit_REDIST_VERSION "14.40.33807")

include("${CMAKE_CURRENT_LIST_DIR}/portfile_winsdk.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/portfile_toolkit.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/portfile_msbuild.cmake")

if(NOT VCPKG_CRT_LINKAGE STREQUAL "static")
    file(COPY "${CURRENT_PACKAGES_DIR}/VS/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}/x64/Microsoft.VC143.CRT/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY "${CURRENT_PACKAGES_DIR}/VS/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}/x64/Microsoft.VC143.MFC/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY "${CURRENT_PACKAGES_DIR}/WinSDK/Windows Kits/10/Redist/${WinSDK_VERSION}/ucrt/DLLs/x64/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

    if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${CURRENT_PACKAGES_DIR}/VS/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}/debug_nonredist/x64/Microsoft.VC143.DebugCRT/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY "${CURRENT_PACKAGES_DIR}/VS/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}/debug_nonredist/x64/Microsoft.VC143.DebugMFC/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY "${CURRENT_PACKAGES_DIR}/WinSDK/Windows Kits/10/bin/${WinSDK_VERSION}/x64/ucrt" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY "${CURRENT_PACKAGES_DIR}/WinSDK/Windows Kits/10/Redist/${WinSDK_VERSION}/ucrt/DLLs/x64/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin" PATTERN "ucrtbase.dll" EXCLUDE)
    endif()
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/msvc-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/msvc-env.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/msvc-env.cmake" @ONLY)
