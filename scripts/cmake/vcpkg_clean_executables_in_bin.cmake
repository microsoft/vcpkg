function(z_vcpkg_clean_executables_in_bin_remove_directory_if_empty directory)
    if(NOT EXISTS "${directory}")
        return()
    endif()

    if(NOT IS_DIRECTORY "${directory}")
        message(FATAL_ERROR "${directory} must be a directory")
    endif()

    file(GLOB items "${directory}/*")
    if("${items}" STREQUAL "")
        file(REMOVE_RECURSE "${directory}")
    endif()
endfunction()


function(vcpkg_clean_executables_in_bin)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "FILE_NAMES")

    if(NOT DEFINED arg_FILE_NAMES)
        message(FATAL_ERROR "FILE_NAMES must be specified.")
    endif()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()


    foreach(file_name IN LISTS arg_FILE_NAMES)
        file(REMOVE
            "${CURRENT_PACKAGES_DIR}/bin/${file_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            "${CURRENT_PACKAGES_DIR}/debug/bin/${file_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            "${CURRENT_PACKAGES_DIR}/bin/${file_name}.pdb"
            "${CURRENT_PACKAGES_DIR}/debug/bin/${file_name}.pdb"
        )
        if(NOT VCPKG_TARGET_BUNDLE_SUFFIX STREQUAL "")
            file(REMOVE_RECURSE
                "${CURRENT_PACKAGES_DIR}/bin/${file_name}${VCPKG_TARGET_BUNDLE_SUFFIX}"
                "${CURRENT_PACKAGES_DIR}/debug/bin/${file_name}${VCPKG_TARGET_BUNDLE_SUFFIX}"
            )
        endif()
    endforeach()

    z_vcpkg_clean_executables_in_bin_remove_directory_if_empty("${CURRENT_PACKAGES_DIR}/bin")
    z_vcpkg_clean_executables_in_bin_remove_directory_if_empty("${CURRENT_PACKAGES_DIR}/debug/bin")
endfunction()
