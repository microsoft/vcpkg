function(vcpkg_from_sourceforge)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "DISABLE_SSL;NO_REMOVE_ONE_LEVEL"
        "OUT_SOURCE_PATH;REPO;REF;SHA512;FILENAME;WORKING_DIRECTORY"
        "PATCHES")

    foreach(arg_name IN ITEMS OUT_SOURCE_PATH SHA512 REPO FILENAME)
        if(NOT DEFINED "arg_${arg_name}")
            message(FATAL_ERROR "${arg_name} is required.")
        endif()
    endforeach()

    if(arg_DISABLE_SSL)
        message(WARNING "DISABLE_SSL has been deprecated and has no effect")
    endif()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    vcpkg_download_sourceforge(ARCHIVE
        REPO "${arg_REPO}"
        REF "${arg_REF}"
        SHA512 "${arg_SHA512}"
        FILENAME "${arg_FILENAME}"
    )

    set(no_remove_one_level_param "")
    if(arg_NO_REMOVE_ONE_LEVEL)
        set(no_remove_one_level_param "NO_REMOVE_ONE_LEVEL")
    endif()
    set(working_directory_param "")
    if(DEFINED arg_WORKING_DIRECTORY)
        set(working_directory_param "WORKING_DIRECTORY" "${arg_WORKING_DIRECTORY}")
    endif()
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${ARCHIVE}"
        REF "${sanitized_ref}"
        ${no_remove_one_level_param}
        ${working_directory_param}
        PATCHES ${arg_PATCHES}
    )

    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
