include_guard(GLOBAL)

function(setup_msvc_env)
  if(NOT DEFINED ENV{MSVC_TOOLCHAIN_ENV_ALREADY_SET})
    set(MSVC_DIR "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/..")
    set(VS_DIR "${MSVC_DIR}/@subdir@VS")
    set(SDK_DIR "${MSVC_DIR}/@subdir@WinSDK")

    set(WinSDK_VERSION "@WinSDK_VERSION@")
    set(VCToolkit_VERSION "@VCToolkit_VERSION@")
    set(VCToolkit_REDIST_VERSION "@VCToolkit_REDIST_VERSION@")

    set(systemroot "$ENV{SystemRoot}")
    string(REPLACE "\\" "/" systemroot "${systemroot}")

    set(LIB 
          "${VS_DIR}/VC/Tools/MSVC/${VCToolkit_VERSION}/ATLMFC/lib/x64"
          "${VS_DIR}/VC/Tools/MSVC/${VCToolkit_VERSION}/lib/x64"
          "${SDK_DIR}/Windows Kits/NETFXSDK/4.8.1/lib/um/x64" #
          "${SDK_DIR}/Windows Kits/10/lib/${WinSDK_VERSION}/ucrt/x64"
          "${SDK_DIR}/Windows Kits/10/lib/${WinSDK_VERSION}/um/x64"
    )
    cmake_path(CONVERT "${LIB}" TO_NATIVE_PATH_LIST LIB NORMALIZE)
    set(ENV{LIB} "${LIB}")
    set(LIBPATH 
          "${VS_DIR}/VC/Tools/MSVC/${VCToolkit_VERSION}/ATLMFC/lib/x64"
          "${VS_DIR}/VC/Tools/MSVC/${VCToolkit_VERSION}/lib/x64"
          "${VS_DIR}/VC/Tools/MSVC/${VCToolkit_VERSION}/lib/x86/store/references"
          "${SDK_DIR}/Windows Kits/10/UnionMetadata/${WinSDK_VERSION}"
          "${SDK_DIR}/Windows Kits/10/References/${WinSDK_VERSION}"
          "${systemroot}/Microsoft.NET/Framework64/v4.0.30319"
    )
    cmake_path(CONVERT "${LIBPATH}" TO_NATIVE_PATH_LIST LIBPATH NORMALIZE)
    set(ENV{LIBPATH} "${LIBPATH}")
    set(INCLUDE
          "${VS_DIR}/VC/Tools/MSVC/${VCToolkit_VERSION}/include"
          "${VS_DIR}/VC/Tools/MSVC/${VCToolkit_VERSION}/ATLMFC/include"
          "${VS_DIR}/VC/Auxiliary/VS/include"
          "${SDK_DIR}/Windows Kits/10/include/${WinSDK_VERSION}/ucrt"
          "${SDK_DIR}/Windows Kits/10/include/${WinSDK_VERSION}/um"
          "${SDK_DIR}/Windows Kits/10/include/${WinSDK_VERSION}/shared"
          "${SDK_DIR}/Windows Kits/10/include/${WinSDK_VERSION}/winrt"
          "${SDK_DIR}/Windows Kits/10/include/${WinSDK_VERSION}/cppwinrt"
          "${SDK_DIR}/Windows Kits/NETFXSDK/4.8.1/include/um" #
    )
    cmake_path(CONVERT "${INCLUDE}" TO_NATIVE_PATH_LIST INCLUDE NORMALIZE)
    set(ENV{INCLUDE} "${INCLUDE}")
    set(EXTERNAL_INCLUDE ${INCLUDE})
    cmake_path(CONVERT "${EXTERNAL_INCLUDE}" TO_NATIVE_PATH_LIST EXTERNAL_INCLUDE NORMALIZE)

    set(ENV{EXTERNAL_INCLUDE} "${EXTERNAL_INCLUDE}")
    set(ENV{DevEnvDir} "${VS_DIR}/Common7/IDE/")
    set(ENV{ExtensionSdkDir} "${SDK_DIR}/Windows Kits/10/ExtensionSDKs")
    set(ENV{UniversalCRTSdkDir} "${SDK_DIR}/Windows Kits/10/")
    set(ENV{UCRTVersion} "${WinSDK_VERSION}")
    set(ENV{VCIDEInstallDir} "${VS_DIR}/Common7/IDE/VC/")
    set(ENV{VCINSTALLDIR} "${VS_DIR}/VC/")
    set(ENV{VCToolsInstallDir} "${VS_DIR}/VC/Tools/MSVC/${VCToolkit_VERSION}/")
    set(ENV{VCToolsRedistDir} "${VS_DIR}/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}/")
    set(ENV{VCToolsVersion} "${VCToolkit_VERSION}")
    set(ENV{VisualStudioVersion} "17.0")
    set(ENV{VS170COMNTOOLS} "${VS_DIR}/Common7/Tools/")
    set(ENV{VSINSTALLDIR} "${VS_DIR}/")
    set(WindowsLibPath 
          "${SDK_DIR}/Windows Kits/10/UnionMetadata/${WinSDK_VERSION}"
          "${SDK_DIR}/Windows Kits/10/References/${WinSDK_VERSION}"
    )
    cmake_path(CONVERT "${WindowsLibPath}" TO_NATIVE_PATH_LIST WindowsLibPath NORMALIZE)
    set(ENV{WindowsLibPath} "${WindowsLibPath}")
    set(ENV{WindowsSdkBinPath} "${SDK_DIR}/Windows Kits/10/bin/")
    set(ENV{WindowsSdkDir} "${SDK_DIR}/Windows Kits/10/")
    set(ENV{WindowsSDKLibVersion} "${WinSDK_VERSION}\\")
    set(ENV{WindowsSdkVerBinPath} "${SDK_DIR}/Windows Kits/10/bin/${WinSDK_VERSION}/")
    set(ENV{WindowsSDKVersion} "${WinSDK_VERSION}\\")
    set(WindowsSDK_ExecutablePath_x64 "${SDK_DIR}/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8.1 Tools/x64/") #
    set(WindowsSDK_ExecutablePath_x86 "${SDK_DIR}/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8.1 Tools/") #
    set(ADD_TO_PATH 
          "${VS_DIR}/VC/Tools/MSVC/${VCToolkit_VERSION}/bin/HostX64/x64"
          #${VS_DIR}/Common7/IDE/VC/VCPackages
          #${VS_DIR}/Common7/IDE/CommonExtensions/Microsoft/TestWindow
          #${VS_DIR}/Common7/IDE/CommonExtensions/Microsoft/TeamFoundation/Team Explorer
          "${VS_DIR}/MSBuild/Current/bin/Roslyn"
          "${SDK_DIR}/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8.1 Tools/x64/" #
          #C:/Program Files (x86)/HTML Help Workshop
          #${VS_DIR}/Common7/IDE/CommonExtensions/Microsoft/FSharp/Tools
          #${VS_DIR}/Team Tools/DiagnosticsHub/Collector
          "${SDK_DIR}/Windows Kits/10/bin/${WinSDK_VERSION}/x64"
          "${SDK_DIR}/Windows Kits/10/bin/x64"
          "${VS_DIR}/MSBuild/Current/Bin/"
          #${VS_DIR}/Common7/IDE/
          #${VS_DIR}/Common7/Tools/
    )
    cmake_path(CONVERT "$ENV{PATH}" TO_CMAKE_PATH_LIST path)
    list(PREPEND path ${ADD_TO_PATH})

    cmake_path(CONVERT "${path}" TO_NATIVE_PATH_LIST path NORMALIZE)
    set(ENV{PATH} "${path}")

    set(ENV{CMAKE_WINDOWS_KITS_10_DIR} "$ENV{WindowsSdkDir}")

    set(ENV{MSVC_TOOLCHAIN_ENV_ALREADY_SET} "1")
  endif()
endfunction()
