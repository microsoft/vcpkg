set(WINDOWS_APP_SDK_VERSION 1.3.230724000)

set(_winui_download_dir "${DOWNLOADS}/WindowsAppSDK")
set(_winui_root_dir "${_winui_download_dir}/Microsoft.WindowsAppSDK.${WINDOWS_APP_SDK_VERSION}")

set(WINDOWS_APP_SDK_ROOT_DIR "${_winui_root_dir}")

# Download the Windows App SDK
vcpkg_find_acquire_program(NUGET)
message(STATUS "Installing NuGet: Microsoft.WindowsAppSDK into ${_winui_download_dir}")
vcpkg_execute_required_process(
    COMMAND ${NUGET} install Microsoft.WindowsAppSDK
        -Version ${WINDOWS_APP_SDK_VERSION} 
        -OutputDirectory ${_winui_download_dir}
        -Source https://api.nuget.org/v3/index.json
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME "winui-nuget-install"
)
vcpkg_get_windows_sdk(_winsdk_version)

set(_winsdk_bin_dir "$ENV{WindowsSdkDir}bin\\${_winsdk_version}\\x64")

# Generate the IDL from the WINMD
file(GLOB _winui_winmd_files_to_process 
    "${_winui_root_dir}/lib/uap10.0.18362/*.winmd"
    "${_winui_root_dir}/lib/uap10.0/*.winmd")
foreach(_winui_winmd_file IN LISTS _winui_winmd_files_to_process)
    get_filename_component(_winui_winmd_filename_wle "${_winui_winmd_file}" NAME_WLE)
    if (EXISTS "${_winui_root_dir}/include/${_winui_winmd_filename_wle}.idl")
        message(STATUS "Using cached IDL: ${_winui_root_dir}/include/${_winui_winmd_filename_wle}.idl")
    else()
        message(STATUS "Generating IDL from ${_winui_winmd_filename_wle}.winmd into ${_winui_root_dir}/include")
        vcpkg_execute_required_process(
            COMMAND "${_winsdk_bin_dir}\\winmdidl.exe"
                "${_winui_winmd_file}"
                /metadata_dir:C:\\Windows\\System32\\WinMetadata
                /nologo
                /outdir:.
            WORKING_DIRECTORY "${_winui_root_dir}/include"
            LOGNAME "winui-winmdidl-${_winui_winmd_filename_wle}-${TARGET_TRIPLET}"
        )
        # file(COPY ${_winui_winmd_file} DESTINATION "${_winui_root_dir}/include")
    endif()
endforeach()

# Compile the IDL into H and WINMD
file(GLOB _winui_idl_files "${_winui_root_dir}/include/*.idl")
# Remove Microsoft.Windows.ApplicationModel.Resources as it crashes the compiler
list(FILTER _winui_idl_files EXCLUDE REGEX "Microsoft.Windows.ApplicationModel.Resources.idl")
foreach(_winui_idl_file IN LISTS _winui_idl_files)
    get_filename_component(_winui_idl_filename "${_winui_idl_file}" NAME)
    get_filename_component(_winui_idl_filename_wle "${_winui_idl_file}" NAME_WLE)
    if (EXISTS "${_winui_root_dir}/include/${_winui_idl_filename_wle}.winmd")
        message(STATUS "Using cached WINMD: ${_winui_root_dir}/include/${_winui_idl_filename_wle}.winmd")
    else()
        message(STATUS "Compiling IDL from ${_winui_idl_filename} into ${_winui_root_dir}/include")
        vcpkg_execute_required_process(
            COMMAND "${_winsdk_bin_dir}\\midlrt.exe" 
                "${_winui_idl_filename}" 
                /metadata_dir C:\\Windows\\System32\\WinMetadata
                /ns_prefix
                /nomidl
            WORKING_DIRECTORY "${_winui_root_dir}/include"
            LOGNAME "winui-midlrt-${_winui_idl_filename_wle}-${TARGET_TRIPLET}"
        )
    endif()
endforeach()

function(windowsappsdk_copy)
    cmake_parse_arguments(_winui "" "DEST" "" ${ARGN})

    if(NOT DEFINED _winui_DEST)
        message(FATAL_ERROR "DEST is a required argument to windowsappsdk_copy.")
    endif()

    message(STATUS "Copying Windows App SDK headers into ${_winui_DEST}/include")
    file(GLOB _winui_include "${_winui_root_dir}/include/*.h")
    file(COPY ${_winui_include} DESTINATION "${_winui_DEST}/include")
    file(GLOB _winui_include_winrt "${_winui_root_dir}/include/winrt/*.h")
    file(COPY ${_winui_include_winrt} DESTINATION "${_winui_DEST}/include/winrt")
    
    message(STATUS "Copying Windows App SDK libs into ${_winui_DEST}/lib")
    file(GLOB _winui_libs_x86 "${_winui_root_dir}/lib/win10-x86/*.lib")
    file(COPY ${_winui_libs_x86} DESTINATION "${_winui_DEST}/lib/x86")
    file(GLOB _winui_libs_x64 "${_winui_root_dir}/lib/win10-x64/*.lib")
    file(COPY ${_winui_libs_x64} DESTINATION "${_winui_DEST}/lib/x64")
    file(GLOB _winui_libs_arm64 "${_winui_root_dir}/lib/win10-arm64/*.lib")
    file(COPY ${_winui_libs_arm64} DESTINATION "${_winui_DEST}/lib/arm64")
endfunction()
