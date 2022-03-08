set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(VCPKG_TARGET_IS_WINDOWS)
    set(program_name python)
    set(program_version 2.7.18)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(tool_subdirectory "python-${program_version}-x86")
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}.msi")
        set(download_filename "python-${program_version}.msi")
        set(download_sha512 2c112733c777ddbf189b0a54047a9d5851ebce0564cc38b9687d79ce6c7a09006109dbad8627fb1a60c3ad55e261db850d9dfa454af0533b460b2afc316fe115)
    else()
        set(tool_subdirectory "python-${program_version}-x64")
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}.amd64.msi")
        set(download_filename "python-${program_version}.amd64.msi")
        set(download_sha512 6a81a413b80fd39893e7444fd47efa455d240cbb77a456c9d12f7cf64962b38c08cfa244cd9c50a65947c40f936c6c8c5782f7236d7b92445ab3dd01e82af23e)
    endif()
    set(paths_to_search "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

    vcpkg_download_distfile(archive_path
        URLS ${download_urls}
        SHA512 "${download_sha512}"
        FILENAME "${download_filename}"
    )
    set(output_path "${CURRENT_PACKAGES_DIR}/tools")
    file(MAKE_DIRECTORY "${output_path}")
    cmake_path(NATIVE_PATH archive_path archive_path_native) # lessmsi is a bit picky about path formats.
    message(STATUS "Extracting Python2 ...")
    vcpkg_execute_in_download_mode(
                    COMMAND "${CURRENT_INSTALLED_DIR}/tools/vcpkg-tool-lessmsi/lessmsi.exe" x "${archive_path_native}" # Using output_path here does not work in bash
                    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools" 
                    OUTPUT_FILE "lessmsi-${arg_FILENAME}-out.log"
                    ERROR_FILE "lessmsi-${arg_FILENAME}-err.log"
                    RESULT_VARIABLE error_code
                )
    if(error_code)
        message(FATAL_ERROR "Couldn't extract Python2 with lessmsi!")
    endif()
    message(STATUS "Extracting Python2 ... finished!")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/python-2.7.18.amd64/SourceDir/" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/python-2.7.18.amd64")
    z_vcpkg_find_acquire_program_find_internal("PYTHON2"
        INTERPRETER "${interpreter}"
        PATHS ${paths_to_search}
        NAMES ${program_name}
    )
    message(STATUS "Using python2: ${PYTHON2}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/version.txt" "${program_version}") # For vcpkg_find_acquire_program
endif()

