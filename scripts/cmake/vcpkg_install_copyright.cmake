function(vcpkg_install_copyright)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "FILE_LIST")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_FILE_LIST)
        message(FATAL_ERROR "FILE_LIST must be specified")
    endif()

    list(LENGTH arg_FILE_LIST FILE_LIST_LENGTH)
    if(FILE_LIST_LENGTH LESS_EQUAL 1)
        message(FATAL_ERROR "Don't use ${CMAKE_CURRENT_FUNCTION} to install a single license file.")
    endif()

    set(out_string "")
    message(STATUS "Files: ${arg_FILE_LIST}")

    foreach(file_item IN LISTS arg_FILE_LIST)
        if(NOT EXISTS "${file_item}" OR IS_DIRECTORY "${file_item}")
            message(FATAL_ERROR "The file ${file_item} does not exist or is a directory.")
        endif()

        get_filename_component(file_name ${file_item} NAME)
        file(READ "${file_item}" file_contents)

        string(APPEND out_string "${file_name}:\n\n${file_contents}\n\n")
    endforeach()

    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${out_string}")
endfunction()
