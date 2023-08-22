message(WARNING ".Net framework 4.7.2 is required, please install it before installing easyhook.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EasyHook/EasyHook
    REF v2.7.7097.0
    SHA512 D0CA5B64E77F6281B2DD7EE0DC492A9B07DDB60A9F514037938CC3E3FFA5DD57C95CB630E18C02C984A89070839E4188044896D4EE57A21E43E6EA3A4918255A
    HEAD_REF master
    PATCHES fix-build.patch
)

# Use /Z7 rather than /Zi to avoid "fatal error C1090: PDB API call failed, error code '23': (0x00000006)"
foreach(VCXPROJ IN ITEMS
    "${SOURCE_PATH}/EasyHookDll/EasyHookDll.vcxproj"
    "${SOURCE_PATH}/Examples/UnmanagedHook/UnmanagedHook.vcxproj")
    vcpkg_replace_string(
        "${VCXPROJ}"
        "<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>"
        "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
    )
    vcpkg_replace_string(
        "${VCXPROJ}"
        "<DebugInformationFormat>EditAndContinue</DebugInformationFormat>"
        "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
    )
    vcpkg_replace_string(
        "${VCXPROJ}"
        "<MinimalRebuild>true</MinimalRebuild>"
        ""
    )
endforeach()

# Use modern .NET Framework
foreach(CSPROJ IN ITEMS
    "${SOURCE_PATH}/EasyHook/EasyHook.csproj"
    "${SOURCE_PATH}/EasyHookSvc/EasyHookSvc.csproj"
    "${SOURCE_PATH}/EasyLoad/EasyLoad.csproj"
    "${SOURCE_PATH}/Examples/FileMon/FileMon.csproj"
    "${SOURCE_PATH}/Examples/FileMonInject/FileMonInject.csproj"
    "${SOURCE_PATH}/Examples/FileMonitorController/FileMonitorController.csproj"
    "${SOURCE_PATH}/Examples/FileMonitorInterceptor/FileMonitorInterceptor.csproj"
    "${SOURCE_PATH}/Examples/FileMonitorInterface/FileMonitorInterface.csproj"
    "${SOURCE_PATH}/Examples/ProcessMonitor/ProcessMonitor.csproj"
    "${SOURCE_PATH}/Examples/ProcMonInject/ProcMonInject.csproj"
    "${SOURCE_PATH}/Test/ComplexParameterInject/ComplexParameterInject.csproj"
    "${SOURCE_PATH}/Test/ComplexParameterTest/ComplexParameterTest.csproj"
    "${SOURCE_PATH}/Test/EasyHook.Tests/EasyHook.Tests.csproj"
    "${SOURCE_PATH}/Test/ManagedTarget/ManagedTarget.csproj"
    "${SOURCE_PATH}/Test/ManagedTest/ManagedTest.csproj"
    "${SOURCE_PATH}/Test/MultipleHooks/MultipleHooks/MultipleHooks.csproj"
    "${SOURCE_PATH}/Test/MultipleHooks/SimpleHook1/SimpleHook1.csproj"
    "${SOURCE_PATH}/Test/MultipleHooks/SimpleHook2/SimpleHook2.csproj"
    "${SOURCE_PATH}/Test/TestFuncHooks/TestFuncHooks.csproj")

    vcpkg_replace_string(
        "${CSPROJ}"
        "<TargetFrameworkVersion>v4.0</TargetFrameworkVersion>"
        "<TargetFrameworkVersion>4.7.2</TargetFrameworkVersion>"
    )
    vcpkg_replace_string(
        "${CSPROJ}"
        "<TargetFrameworkProfile>Client</TargetFrameworkProfile>"
        ""
    )
endforeach()

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH EasyHook.sln
    TARGET EasyHookDll
    RELEASE_CONFIGURATION "netfx4-Release"
    DEBUG_CONFIGURATION "netfx4-Debug"
)

# Remove the mismatch rebuild library
if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/AUX_ULIB_x64.LIB")
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/AUX_ULIB_x64.LIB")
    endif()
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/AUX_ULIB_x86.LIB")
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/AUX_ULIB_x86.LIB")
    endif()
endif()

# These libraries are useless, so remove.
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/EasyHook.dll" "${CURRENT_PACKAGES_DIR}/bin/EasyHook.pdb")
endif()
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/EasyHook.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/EasyHook.pdb")
endif()

# Install includes
file(INSTALL "${SOURCE_PATH}/Public/easyhook.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/easyhook")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
