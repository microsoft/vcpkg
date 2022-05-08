set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

file(READ "${CURRENT_PORT_DIR}/vcpkg.json" manifest_contents)
string(JSON version GET "${manifest_contents}" "version-string")
string(REPLACE "." "" versionraw "${version}")
if(VCPKG_TARGET_IS_WINDOWS)
    set(name_msg 7z)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(arch_suffix "")
        set(hash 103210153e60b4234015796bb5f12483f99b5909df8c2fe5c9d3a823d4bdc721602a5261ad794e5280ff9f0d5f79add4e2a732dfb087fe8b4844d789acb8ea42)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(arch_suffix "-x64")
        set(hash d55b44f1255d1b0e629719383a600a7e83dc6378d470096337b886ce24684d26bcc2b04f9cea39ad888179edce23ad2bd0e8e1863ddc40106c176adece8c012d)
    endif()
    set(name_folder "${name_msg}${versionraw}${arch_suffix}")
    set(name_msi "${name_folder}.msi")
    set(url "https://www.7-zip.org/a/${name_msi}")

    vcpkg_download_distfile(archive_path
        URLS "${url}"
        SHA512 "${hash}"
        FILENAME "${name_msi}"
    )

    set(output_path "${CURRENT_PACKAGES_DIR}/manual-tools") # vcpkg.cmake adds everything in /tools to CMAKE_PROGRAM_PATH. That is not desired for Python2
    file(MAKE_DIRECTORY "${output_path}")
    cmake_path(NATIVE_PATH archive_path archive_path_native) # lessmsi is a bit picky about path formats.
    message(STATUS "Extracting ${name_msg} ...")
    vcpkg_execute_in_download_mode(
                    COMMAND "${CURRENT_HOST_INSTALLED_DIR}/tools/vcpkg-tool-lessmsi/lessmsi.exe" x "${archive_path_native}" # Using output_path here does not work in bash
                    WORKING_DIRECTORY "${output_path}" 
                    OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/lessmsi-${TARGET_TRIPLET}-out.log"
                    ERROR_FILE "${CURRENT_BUILDTREES_DIR}/lessmsi-${TARGET_TRIPLET}-err.log"
                    RESULT_VARIABLE error_code
                )
    if(error_code)
        message(FATAL_ERROR "Couldn't extract ${name_msg} with lessmsi!")
    endif()
    message(STATUS "Extracting ${name_msg} ... finished!")
    file(RENAME "${output_path}/${name_folder}/SourceDir/Files/7-Zip" "${output_path}/${PORT}/")
    file(REMOVE_RECURSE "${output_path}/${name_folder}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
endif()


