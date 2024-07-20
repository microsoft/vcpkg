function(vcpkg_replace_strings)
    # Ensure there is at least one argument (the filename)
    if(NOT ARGV)
        message(FATAL_ERROR "No arguments provided. At least a filename is required.")
        return()
    endif()

    # Read the file contents
    set(filename ${ARGV0})
    file(READ "${filename}" contents)
    string(SHA512 before_hash "${contents}")

    # Initialize variables
    set(index 1)
    set(ignore_unchanged OFF)

    # Check for optional IGNORE_UNCHANGED argument
    if(${ARGV_COUNT} GREATER 1 AND "${ARGV1}" STREQUAL "IGNORE_UNCHANGED")
        set(ignore_unchanged ON)
        math(EXPR index "${index} + 1")
    endif()

    # Process remaining arguments for REPLACE and REGEX_REPLACE
    while(${ARGV_COUNT} GREATER ${index})
        if("${ARGV${index}}" STREQUAL "REPLACE" OR "${ARGV${index}}" STREQUAL "REGEX_REPLACE")
            set(operation ${ARGV${index}})
            string(REPLACE "_" " " operation ${operation})
            math(EXPR index "${index} + 1")
            
            # Check for <from> argument
            if(${ARGV_COUNT} LESS ${index} + 1)
                message(FATAL_ERROR "${operation} requires both <from> and <to> arguments.")
                return()
            endif()
            set(from ${ARGV${index}})
            math(EXPR index "${index} + 1")
            
            # Check for <to> argument
            if(${ARGV_COUNT} LESS ${index} + 1)
                message(FATAL_ERROR "${operation} requires both <from> and <to> arguments.")
                return()
            endif()
            set(to ${ARGV${index}})
            math(EXPR index "${index} + 1")
            
            # Replace string
            string(${operation} "${from}" "${to}" contents "${contents}")
        else()
            message(FATAL_ERROR "Invalid operation or argument order. Expected REPLACE or REGEX_REPLACE.")
            return()
        endif()
    endwhile()

    string(SHA512 after_hash "${contents}")
    if(NOT ignore_unchanged AND "${before_hash}" STREQUAL "${after_hash}")
        message("${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" "vcpkg_replace_strings made no changes.")
    endif()
    file(WRITE "${filename}" "${contents}")
endfunction()
