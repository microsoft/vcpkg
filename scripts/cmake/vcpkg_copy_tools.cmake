function(z_copy_tool_file)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "TOOLNAME;DIRECTORY;DESTINATION" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_TOOLNAME)
        message(FATAL_ERROR "TOOLNAME must be specified.")
    endif()

    if(NOT DEFINED arg_DIRECTORY)
        message(FATAL_ERROR "DIRECTORY must be specified.")
    endif()

    if(NOT DEFINED arg_DESTINATION)
        message(FATAL_ERROR "DESTINATION must be specified.")
    endif()

    if(NOT EXISTS ${arg_DESTINATION})
        file(MAKE_DIRECTORY ${arg_DESTINATION})
    endif()

    # This is a simple and tricky approach to support dynamic build for linux.
    if(VCPKG_HOST_IS_LINUX)
        # Detect the file type, only deal with dynamic executable in this way.
        execute_process(
            COMMAND file -i -b ${arg_DIRECTORY}/${arg_TOOLNAME}
            OUTPUT_VARIABLE file_mime_type
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(file_mime_type STREQUAL "application/x-sharedlib; charset=binary")
            cmake_path(RELATIVE_PATH arg_DESTINATION
                    BASE_DIRECTORY "${CURRENT_PACKAGES_DIR}"
                    OUTPUT_VARIABLE relative_tool_dir
            )
            # Set the Z_CURRENT_TOOL_DEPENDENCIES_SEARCH_DIR variable, which is signed
            # to LD_LIBRARY_PATH within templates/execute_tool.sh.in script file.
            if(relative_tool_dir MATCHES "/debug/")
                set(Z_CURRENT_TOOL_DEPENDENCIES_SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/lib:${CURRENT_INSTALLED_DIR}/debug/lib")
            else()
                set(Z_CURRENT_TOOL_DEPENDENCIES_SEARCH_DIR "${CURRENT_PACKAGES_DIR}/lib:${CURRENT_INSTALLED_DIR}/lib")
            endif()
            # Here's the trick...
            set(Z_CURRENT_TOOL_PATH "${arg_DESTINATION}/${arg_TOOLNAME}.original")
            file(COPY_FILE "${arg_DIRECTORY}/${arg_TOOLNAME}" "${Z_CURRENT_TOOL_PATH}")
            configure_file(${SCRIPTS}/templates/execute_tool.sh.in ${arg_DESTINATION}/${arg_TOOLNAME})
            # Done~
            return()
        endif()
    endif()
    
    file(COPY "${arg_DIRECTORY}/${arg_TOOLNAME}" DESTINATION "${arg_DESTINATION}")
endfunction()

function(vcpkg_copy_tools)
    cmake_parse_arguments(PARSE_ARGV 0 arg "AUTO_CLEAN" "SEARCH_DIR;DESTINATION" "TOOL_NAMES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_TOOL_NAMES)
        message(FATAL_ERROR "TOOL_NAMES must be specified.")
    endif()

    if(NOT DEFINED arg_DESTINATION)
        set(arg_DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()

    if(NOT DEFINED arg_SEARCH_DIR)
        set(arg_SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin")
    elseif(NOT IS_DIRECTORY "${arg_SEARCH_DIR}")
        message(FATAL_ERROR "SEARCH_DIR (${arg_SEARCH_DIR}) must be a directory")
    endif()

    foreach(tool_name IN LISTS arg_TOOL_NAMES)
        set(tool_path "${arg_SEARCH_DIR}/${tool_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        set(tool_pdb "${arg_SEARCH_DIR}/${tool_name}.pdb")
        if(EXISTS "${tool_path}")
            # Tricky helper to support dynamic build for linux.
            z_copy_tool_file(
                TOOLNAME "${tool_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
                DIRECTORY "${arg_SEARCH_DIR}"
                DESTINATION "${arg_DESTINATION}"
            )
            # Original tool file copying approach. Reserve it here to be enable when a better way is figured out.
            #file(COPY "${tool_path}" DESTINATION "${arg_DESTINATION}")
        elseif(NOT "${VCPKG_TARGET_BUNDLE_SUFFIX}" STREQUAL "" AND NOT "${VCPKG_TARGET_BUNDLE_SUFFIX}" STREQUAL "${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
            set(bundle_path "${arg_SEARCH_DIR}/${tool_name}${VCPKG_TARGET_BUNDLE_SUFFIX}")
            if(EXISTS "${bundle_path}")
                file(COPY "${bundle_path}" DESTINATION "${arg_DESTINATION}")
            else()
                message(FATAL_ERROR "Couldn't find tool \"${tool_name}\":
    neither \"${tool_path}\" nor \"${bundle_path}\" exists")
            endif()
        else()
            message(FATAL_ERROR "Couldn't find tool \"${tool_name}\":
    \"${tool_path}\" does not exist")
        endif()
        if(EXISTS "${tool_pdb}")
            file(COPY "${tool_pdb}" DESTINATION "${arg_DESTINATION}")
        endif()
    endforeach()

    if(arg_AUTO_CLEAN)
        vcpkg_clean_executables_in_bin(FILE_NAMES ${arg_TOOL_NAMES})
    endif()

    vcpkg_copy_tool_dependencies("${arg_DESTINATION}")
endfunction()
