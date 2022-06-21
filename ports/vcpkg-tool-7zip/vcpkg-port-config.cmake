include_guard(GLOBAL)

set(output_path "${DOWNLOADS}/7z")
set(versionraw 2107)
set(name_msg 7z)
if(x64 STREQUAL "x86")
    set(arch_suffix "")
    set(hash 103210153e60b4234015796bb5f12483f99b5909df8c2fe5c9d3a823d4bdc721602a5261ad794e5280ff9f0d5f79add4e2a732dfb087fe8b4844d789acb8ea42)
elseif(x64 STREQUAL "x64")
    set(arch_suffix "-x64")
    set(hash d55b44f1255d1b0e629719383a600a7e83dc6378d470096337b886ce24684d26bcc2b04f9cea39ad888179edce23ad2bd0e8e1863ddc40106c176adece8c012d)
endif()
set(name_folder "${name_msg}${versionraw}${arch_suffix}")

find_program(7Z NAMES "${name_msg}" PATHS "${output_path}/${name_folder}/SourceDir/Files/7-Zip/")
if(NOT 7Z)
    include("${CMAKE_CURRENT_LIST_DIR}/../vcpkg-tool-lessmsi/vcpkg-port-config.cmake") # Make sure lessmsi is available
    set(name_msi "${name_folder}.msi")
    set(url "https://www.7-zip.org/a/${name_msi}")
    vcpkg_download_distfile(archive_path
        URLS "${url}"
        SHA512 "${hash}"
        FILENAME "${name_msi}"
    )
    file(MAKE_DIRECTORY "${output_path}")
    cmake_path(NATIVE_PATH archive_path archive_path_native) # lessmsi is a bit picky about path formats.
    message(STATUS "Extracting ${name_msg} ...")
    vcpkg_execute_in_download_mode(
                    COMMAND "${LESSMSI}" x "${archive_path_native}" # Using output_path here does not work in bash
                    WORKING_DIRECTORY "${output_path}" 
                    OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/lessmsi-${TARGET_TRIPLET}-out.log"
                    ERROR_FILE "${CURRENT_BUILDTREES_DIR}/lessmsi-${TARGET_TRIPLET}-err.log"
                    RESULT_VARIABLE error_code
                )
    if(error_code)
        message(FATAL_ERROR "Couldn't extract ${name_msg} with lessmsi!")
    endif()
    message(STATUS "Extracting ${name_msg} ... finished!")
    set(7Z "${output_path}/${name_folder}/SourceDir/Files/7-Zip/7z.exe")
endif()
