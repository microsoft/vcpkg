function(vcpkg_extract_archive)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "ARCHIVE;DESTINATION"
        ""
    )

    foreach(arg_name IN ITEMS ARCHIVE DESTINATION)
        if(NOT DEFINED "arg_${arg_name}")
            message(FATAL_ERROR "${arg_name} is required.")
        endif()
    endforeach()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(EXISTS "${arg_DESTINATION}")
        message(FATAL_ERROR "${arg_DESTINATION} was an extraction target, but it already exists.")
    endif()

    file(MAKE_DIRECTORY "${arg_DESTINATION}")

    cmake_path(GET arg_ARCHIVE EXTENSION archive_extension)
    string(TOLOWER "${archive_extension}" archive_extension)
    if("${archive_extension}" MATCHES [[\.msi$]])
        cmake_path(NATIVE_PATH arg_ARCHIVE archive_native_path)
        cmake_path(NATIVE_PATH arg_DESTINATION destination_native_path)
        cmake_path(GET arg_ARCHIVE PARENT_PATH archive_directory)
        vcpkg_execute_in_download_mode(
            COMMAND msiexec
                /a "${archive_native_path}"
                /qn "TARGETDIR=${destination_native_path}"
            WORKING_DIRECTORY "${archive_directory}"
        )
    elseif("${archive_extension}" MATCHES [[\.7z\.exe$]])
        vcpkg_find_acquire_program(7Z)
        vcpkg_execute_in_download_mode(
            COMMAND ${7Z} x
                "${arg_ARCHIVE}"
                "-o${arg_DESTINATION}"
                -y -bso0 -bsp0
            WORKING_DIRECTORY "${arg_DESTINATION}"
        )
    else()
        vcpkg_execute_in_download_mode(
            COMMAND "${CMAKE_COMMAND}" -E tar xzf "${arg_ARCHIVE}"
            WORKING_DIRECTORY "${arg_DESTINATION}"
        )
    endif()
endfunction()
