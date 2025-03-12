block()
  set(MSBuild_FILES "")
  include("${CMAKE_CURRENT_LIST_DIR}/download_msbuild.cmake")
  set(prefix MSBuild)

  foreach(item IN LISTS ${prefix}_FILES)
    vcpkg_download_distfile(
        downloaded_file
        URLS "${${prefix}_${item}_URL}"
        FILENAME "VS-${VERSION}/MSBuild/${${prefix}_${item}_FILENAME}"
        SHA512 "${${prefix}_${item}_SHA512}"
    )

    list(APPEND vsix_installers "${downloaded_file}")
  endforeach()

  set(counter 0)
  foreach(item IN LISTS vsix_installers)
      vcpkg_execute_required_process(
        COMMAND "${pwsh_exe}" -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_LIST_DIR}/extract-vsix.ps1" "-VsixFile" "${item}" "-ExtractTo" "${CURRENT_PACKAGES_DIR}/compiler/msvc/VS"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "extract_msbuild_${counter}.log"
      )
  endforeach()

  set(msbuild_base "${CURRENT_PACKAGES_DIR}/compiler/MSVC/VS/MSBuild/Microsoft/VC/v170/")
  set(winsdk_props "${msbuild_base}/Microsoft.Cpp.WindowsSDK.props")
  set(vc_common_props "${msbuild_base}/Microsoft.Cpp.Common.props")
  file(READ "${winsdk_props}" winsdk_props_content)
  string(REPLACE 
    [[<_LatestWindowsTargetPlatformVersion>$([Microsoft.Build.Utilities.ToolLocationHelper]::GetLatestSDKTargetPlatformVersion($(SDKIdentifier), $(SDKVersion)))</_LatestWindowsTargetPlatformVersion>]]
    "<_LatestWindowsTargetPlatformVersion>${WinSDK_VERSION}</_LatestWindowsTargetPlatformVersion>" 
    winsdk_props_content 
    "${winsdk_props_content}"
  )
  string(REPLACE 
    [[<WindowsSdkDir_10 Condition="'$(WindowsSdkDir_10)' == ''">$(Registry:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v10.0@InstallationFolder)</WindowsSdkDir_10>]]
    "" 
    winsdk_props_content 
    "${winsdk_props_content}"
  )
  string(REPLACE 
    [[<WindowsSdkDir_10 Condition="'$(WindowsSdkDir_10)' == ''">$(Registry:HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Microsoft SDKs\Windows\v10.0@InstallationFolder)</WindowsSdkDir_10>]]
    "<WindowsSdkDir_10 Condition=\"'$(WindowsSdkDir_10)' == ''\">$(MSBuildThisFileDirectory)\\..\\..\\..\\..\\..\\WinSDK\\Windows Kits\\10\\</WindowsSdkDir_10>" 
    winsdk_props_content 
    "${winsdk_props_content}"
  )
  string(REPLACE 
    [[<UniversalCRTSdkDir_10 Condition="'$(UniversalCRTSdkDir_10)' == ''">$(Registry:HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows Kits\Installed Roots@KitsRoot10)</UniversalCRTSdkDir_10>]]
    "" 
    winsdk_props_content 
    "${winsdk_props_content}"
  )
  string(REPLACE 
    [[<UniversalCRTSdkDir_10 Condition="'$(UniversalCRTSdkDir_10)' == ''">$(Registry:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Kits\Installed Roots@KitsRoot10)</UniversalCRTSdkDir_10>]]
    "<UniversalCRTSdkDir_10 Condition=\"'$(UniversalCRTSdkDir_10)' == ''\">$(MSBuildThisFileDirectory)\\..\\..\\..\\..\\..\\WinSDK\\Windows Kits\\10\\</UniversalCRTSdkDir_10>" 
    winsdk_props_content 
    "${winsdk_props_content}"
  )
  file(WRITE "${winsdk_props}" "${winsdk_props_content}")
  
  file(READ "${vc_common_props}" vc_common_props_contents)
  string(REPLACE 
    [[<VSInstallDir>$(VsInstallRoot)\</VSInstallDir>]]
    "<VSInstallDir>$(MSBuildThisFileDirectory)\\..\\..\\..\\..\\</VSInstallDir>" 
    winsdk_props_content 
    "${winsdk_props_content}"
  )
  file(WRITE "${vc_common_props}" "${vc_common_props_contents}")
endblock()
