include_guard(GLOBAL)
set(version v2.2.0)
find_program(LESSMSI PATHS "${DOWNLOADS}/lessmsi-${version}")
if(NOT LESSMSI)
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/activescott/lessmsi/releases/download/${version}/lessmsi-${version}.zip"
        FILENAME "lessmsi-${version}.zip"
        SHA512 1b66099220175019d7fefe2c4b3f40a92b5bbf077e2100371cf3b9ca98c6ef3bdacb994159a55bcc7759b8890a8cfaeb84f7347ec4f7f23410f185ce5a4124e4
    )
    file(MAKE_DIRECTORY "${DOWNLOADS}/lessmsi-${version}")
    file(ARCHIVE_EXTRACT
        INPUT "${archive_path}"
        DESTINATION "${DOWNLOADS}/lessmsi-${version}"
    )
    set(LESSMSI "${DOWNLOADS}/lessmsi-${version}/lessmsi@VCPKG_TARGET_EXECUTABLE_SUFFIX@")
endif()


function(vcpkg_extract_with_lessmsi)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "MSI;DESTINATION" "")
    if(NOT arg_MSI)
        message(FATAL_ERROR "vcpkg_extract_with_lessmsi: MSI argument is required")
    endif()
    if(NOT arg_DESTINATION)
        message(FATAL_ERROR "vcpkg_extract_with_lessmsi: DESTINATION argument is required")
    endif()

    set(msi "${arg_MSI}")
    cmake_path(GET msi STEM LAST_ONLY componentName)
    cmake_path(GET msi FILENAME filename)
  
    message(STATUS "Extracting '${componentName}'")
    string(REPLACE " " "" componentName "${componentName}")
    set(installLocation "${CURRENT_BUILDTREES_DIR}/lessmsi/${componentName}")
    file(REMOVE_RECURSE "${installLocation}")
    # Create the install location directory
    file(MAKE_DIRECTORY "${installLocation}")
    cmake_path(NATIVE_PATH installLocation NORMALIZE installLocation)
    cmake_path(NATIVE_PATH msi NORMALIZE msi)
    
    # Extract the MSI file
    cmake_path(NATIVE_PATH msi msi_native)
    vcpkg_execute_required_process(
        COMMAND "${LESSMSI}" x "${msi_native}"
        WORKING_DIRECTORY "${installLocation}"
        LOGNAME "lessmsi-${componentName}_cmake.log"
    )
    cmake_path(GET msi FILENAME packstem)
    string(REPLACE ".msi" "" packstem "${packstem}")
    
    # Copy the extracted files to the SDK install folder
    if(EXISTS "${installLocation}/${packstem}/SourceDir/")
        file(COPY "${installLocation}/${packstem}/SourceDir/" DESTINATION "${arg_DESTINATION}/")
    else()
        message(STATUS "Installer '${msi}' had no files! Skipping.")
    endif()
endfunction()