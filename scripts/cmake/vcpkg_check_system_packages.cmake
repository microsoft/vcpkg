macro(z_vcpkg_check_system_package PACKAGE RET)
    set(TOOL_PACKAGES "autoconf;automake;libtool")
    if("${PACKAGE}" IN_LIST TOOL_PACKAGES)
        execute_process(
            COMMAND which -a ${PACKAGE}
            RESULT_VARIABLE RETVAL
            OUTPUT_QUIET
            ERROR_QUIET)
        if(RETVAL AND NOT RETVAL EQUAL 0)
            set(RET FALSE)
        else()
            set(RET TRUE)
        endif()
    elseif("${PACKAGE}" STREQUAL "autoconf-archive")
        # checking autoconf
        set(RET FALSE)
        z_vcpkg_check_system_package(autoconf RET)
        if(RET) # checking autoconf-archive
            file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/check_autoconf_archive")
            file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/check_autoconf_archive")
            file(WRITE "${CURRENT_BUILDTREES_DIR}/check_autoconf_archive/configure.ac"
                "AC_INIT(check_autoconf_archive)\n"
                "m4_ifndef([AX_CHECK_COMPILE_FLAG], [AC_MSG_ERROR(['autoconf-archive' is missing])])\n"
                "AX_CHECK_COMPILE_FLAG([])\n"
                "AC_OUTPUT\n")
            execute_process(
                COMMAND autoreconf
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/check_autoconf_archive"
                RESULT_VARIABLE RETVAL
                OUTPUT_QUIET
                ERROR_QUIET)
            if(RETVAL AND NOT RETVAL EQUAL 0)
                set(RET FALSE)
            else()
                execute_process(
                    COMMAND ./configure
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/check_autoconf_archive"
                    RESULT_VARIABLE RETVAL
                    OUTPUT_QUIET
                    ERROR_QUIET)
                if(RETVAL AND NOT RETVAL EQUAL 0)
                    set(RET FALSE)
                else()
                    set(RET TRUE)
                endif()
            endif()
            file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/check_autoconf_archive")
        endif()
    else()
        set(RET FALSE)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} no rules to check if system package \"${PACKAGE}\" is installed")
    endif()
endmacro()

function(vcpkg_check_system_packages)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        ""
        ""
        "REQUIRED_PACKAGES"
    )
    if(NOT DEFINED arg_REQUIRED_PACKAGES)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} require argument \"REQUIRED_PACKAGES\"")
    endif()
    message(STATUS "Checking required system packages (${arg_REQUIRED_PACKAGES})")
    foreach(PACKAGE IN LISTS arg_REQUIRED_PACKAGES)
        set(RET FALSE)
        z_vcpkg_check_system_package(${PACKAGE} RET)
        if(NOT RET)
            message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} require system package \"${PACKAGE}\"")
        endif()
    endforeach()
endfunction()
