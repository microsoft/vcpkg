function Setup-MSVC-Env {
  param(
      [string]$MSVC_DIR = (Join-Path -Path $PSScriptRoot -ChildPath "..")
  )

  if (-not $env:MSVC_TOOLCHAIN_ENV_ALREADY_SET) {
    # Define paths
    $VS_DIR = Join-Path -Path $MSVC_DIR -ChildPath "@subdir@VS"
    $SDK_DIR = Join-Path -Path $MSVC_DIR -ChildPath "@subdir@WinSDK"

    $WinSDK_VERSION = "@WinSDK_VERSION@"
    $VCToolkit_VERSION = "@VCToolkit_VERSION@"
    $VCToolkit_REDIST_VERSION = "@VCToolkit_REDIST_VERSION@"

    $SystemRoot = $env:SystemRoot -replace "\\", "/"

    # Configure LIB paths
    $LIB = @(
        "$VS_DIR/VC/Tools/MSVC/$VCToolkit_VERSION/ATLMFC/lib/x64",
        "$VS_DIR/VC/Tools/MSVC/$VCToolkit_VERSION/lib/x64",
        "$SDK_DIR/Windows Kits/NETFXSDK/4.8.1/lib/um/x64",
        "$SDK_DIR/Windows Kits/10/lib/$WinSDK_VERSION/ucrt/x64",
        "$SDK_DIR/Windows Kits/10/lib/$WinSDK_VERSION/um/x64"
    )
    $env:LIB = ($LIB -join ";")

    # Configure LIBPATH
    $LIBPATH = @(
        "$VS_DIR/VC/Tools/MSVC/$VCToolkit_VERSION/ATLMFC/lib/x64",
        "$VS_DIR/VC/Tools/MSVC/$VCToolkit_VERSION/lib/x64",
        "$VS_DIR/VC/Tools/MSVC/$VCToolkit_VERSION/lib/x86/store/references",
        "$SDK_DIR/Windows Kits/10/UnionMetadata/$WinSDK_VERSION",
        "$SDK_DIR/Windows Kits/10/References/$WinSDK_VERSION",
        "$SystemRoot/Microsoft.NET/Framework64/v4.0.30319"
    )
    $env:LIBPATH = ($LIBPATH -join ";")

    # Configure INCLUDE paths
    $INCLUDE = @(
        "$VS_DIR/VC/Tools/MSVC/$VCToolkit_VERSION/include",
        "$VS_DIR/VC/Tools/MSVC/$VCToolkit_VERSION/ATLMFC/include",
        "$VS_DIR/VC/Auxiliary/VS/include",
        "$SDK_DIR/Windows Kits/10/include/$WinSDK_VERSION/ucrt",
        "$SDK_DIR/Windows Kits/10/include/$WinSDK_VERSION/um",
        "$SDK_DIR/Windows Kits/10/include/$WinSDK_VERSION/shared",
        "$SDK_DIR/Windows Kits/10/include/$WinSDK_VERSION/winrt",
        "$SDK_DIR/Windows Kits/10/include/$WinSDK_VERSION/cppwinrt",
        "$SDK_DIR/Windows Kits/NETFXSDK/4.8.1/include/um"
    )
    $env:INCLUDE = ($INCLUDE -join ";")
    $env:EXTERNAL_INCLUDE = $env:INCLUDE

    # Environment variables
    $env:DevEnvDir = Join-Path -Path $VS_DIR -ChildPath "Common7/IDE/"
    $env:ExtensionSdkDir = Join-Path -Path $SDK_DIR -ChildPath "Windows Kits/10/ExtensionSDKs"
    $env:UniversalCRTSdkDir = Join-Path -Path $SDK_DIR -ChildPath "Windows Kits/10/"
    $env:UCRTVersion = $WinSDK_VERSION
    $env:VCIDEInstallDir = Join-Path -Path $VS_DIR -ChildPath "Common7/IDE/VC/"
    $env:VCINSTALLDIR = Join-Path -Path $VS_DIR -ChildPath "VC/"
    $env:VCToolsInstallDir = Join-Path -Path $VS_DIR -ChildPath "VC/Tools/MSVC/$VCToolkit_VERSION/"
    $env:VCToolsRedistDir = Join-Path -Path $VS_DIR -ChildPath "VC/Redist/MSVC/$VCToolkit_REDIST_VERSION/"
    $env:VCToolsVersion = $VCToolkit_VERSION
    $env:VisualStudioVersion = "17.0"
    $env:VS170COMNTOOLS = Join-Path -Path $VS_DIR -ChildPath "Common7/Tools/"
    $env:VSINSTALLDIR = $VS_DIR

    # Configure WindowsLibPath
    $WindowsLibPath = @(
        "$SDK_DIR/Windows Kits/10/UnionMetadata/$WinSDK_VERSION",
        "$SDK_DIR/Windows Kits/10/References/$WinSDK_VERSION"
    )
    $env:WindowsLibPath = ($WindowsLibPath -join ";")

    # Additional environment variables
    $env:WindowsSdkBinPath = Join-Path -Path $SDK_DIR -ChildPath "Windows Kits/10/bin/"
    $env:WindowsSdkDir = Join-Path -Path $SDK_DIR -ChildPath "Windows Kits/10/"
    $env:WindowsSDKLibVersion = "$WinSDK_VERSION\"
    $env:WindowsSdkVerBinPath = Join-Path -Path $SDK_DIR -ChildPath "Windows Kits/10/bin/$WinSDK_VERSION/"
    $env:WindowsSDKVersion = "$WinSDK_VERSION\"

    # Configure PATH
    $ADD_TO_PATH = @(
        "$VS_DIR/VC/Tools/MSVC/$VCToolkit_VERSION/bin/HostX64/x64",
        "$VS_DIR/MSBuild/Current/bin/Roslyn",
        "$SDK_DIR/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8.1 Tools/x64/",
        "$SDK_DIR/Windows Kits/10/bin/$WinSDK_VERSION/x64",
        "$SDK_DIR/Windows Kits/10/bin/x64",
        "$VS_DIR/MSBuild/Current/Bin/"
    )
    $env:PATH = ($ADD_TO_PATH + $env:PATH.Split(';')) -join ";"

    $env:CMAKE_WINDOWS_KITS_10_DIR = $env:WindowsSdkDir

    # Mark as set
    $env:MSVC_TOOLCHAIN_ENV_ALREADY_SET = "1"
  }
}

Setup-MSVC-Env