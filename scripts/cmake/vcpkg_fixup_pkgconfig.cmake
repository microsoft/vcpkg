function(z_vcpkg_fixup_pkgconfig_check_files file config)
    set(path_suffix_DEBUG /debug)
    set(path_suffix_RELEASE "")

    if(DEFINED ENV{PKG_CONFIG_PATH})
        set(backup_env_pkg_config_path "$ENV{PKG_CONFIG_PATH}")
    else()
        unset(backup_env_pkg_config_path)
    endif()

    vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH}
        "${CURRENT_PACKAGES_DIR}${path_suffix_${config}}/lib/pkgconfig"
        "${CURRENT_PACKAGES_DIR}/share/pkgconfig"
        "${CURRENT_INSTALLED_DIR}${path_suffix_${config}}/lib/pkgconfig"
        "${CURRENT_INSTALLED_DIR}/share/pkgconfig"
    )

    # First make sure everything is ok with the package and its deps
    cmake_path(GET file STEM LAST_ONLY package_name)
    debug_message("Checking package (${config}): ${package_name}")
    execute_process(
        COMMAND "${PKGCONFIG}" --print-errors --exists "${package_name}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        RESULT_VARIABLE error_var
        OUTPUT_VARIABLE output
        ERROR_VARIABLE  output
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
    )
    if(NOT "${error_var}" EQUAL "0")
        message(FATAL_ERROR "${PKGCONFIG} --exists ${package_name} failed with error code: ${error_var}
    ENV{PKG_CONFIG_PATH}: \"$ENV{PKG_CONFIG_PATH}\"
    output: ${output}"
        )
    else()
        debug_message("pkg-config --exists ${package_name} output: ${output}")
    endif()
    if(DEFINED backup_env_pkg_config_path)
        set(ENV{PKG_CONFIG_PATH} "${backup_env_pkg_config_path}")
    else()
        unset(ENV{PKG_CONFIG_PATH})
    endif()
endfunction()

function(vcpkg_fixup_pkgconfig)
    cmake_parse_arguments(PARSE_ARGV 0 arg 
        "SKIP_CHECK"
        ""
        "RELEASE_FILES;DEBUG_FILES;SYSTEM_LIBRARIES;SYSTEM_PACKAGES;IGNORE_FLAGS"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(DEFINED arg_RELEASE_FILES AND NOT DEFINED arg_DEBUG_FILES)
        message(FATAL_ERROR "DEBUG_FILES must be specified if RELEASE_FILES was specified.")
    endif()
    if(NOT DEFINED arg_RELEASE_FILES AND DEFINED arg_DEBUG_FILES)
        message(FATAL_ERROR "RELEASE_FILES must be specified if DEBUG_FILES was specified.")
    endif()

    if(NOT DEFINED arg_RELEASE_FILES)
        file(GLOB_RECURSE arg_RELEASE_FILES "${CURRENT_PACKAGES_DIR}/**/*.pc")
        file(GLOB_RECURSE arg_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/**/*.pc")
        foreach(debug_file IN LISTS arg_DEBUG_FILES)
            vcpkg_list(REMOVE_ITEM arg_RELEASE_FILES "${debug_file}")
        endforeach()
    endif()

    string(REGEX REPLACE "^([a-zA-Z]):/" [[/\1/]] unix_packages_dir "${CURRENT_PACKAGES_DIR}")
    string(REGEX REPLACE "^([a-zA-Z]):/" [[/\1/]] unix_installed_dir "${CURRENT_INSTALLED_DIR}")

    foreach(config IN ITEMS RELEASE DEBUG)
        debug_message("${config} Files: ${arg_${config}_FILES}")
        if("${VCPKG_BUILD_TYPE}" STREQUAL "debug" AND "${config}" STREQUAL "RELEASE")
            continue()
        endif()
        if("${VCPKG_BUILD_TYPE}" STREQUAL "release" AND "${config}" STREQUAL "DEBUG")
            continue()
        endif()
        foreach(file IN LISTS "arg_${config}_FILES")
            message(STATUS "Fixing pkgconfig file: ${file}")
            cmake_path(GET file PARENT_PATH pkg_lib_search_path)
            if("${config}" STREQUAL "DEBUG")
                set(relative_pc_path "${CURRENT_PACKAGES_DIR}/debug")
                cmake_path(RELATIVE_PATH relative_pc_path BASE_DIRECTORY "${pkg_lib_search_path}")
            else()
                set(relative_pc_path "${CURRENT_PACKAGES_DIR}")
                cmake_path(RELATIVE_PATH relative_pc_path BASE_DIRECTORY "${pkg_lib_search_path}")
            endif()
            #Correct *.pc file
            file(READ "${file}" contents)

            # this normalizes all files to end with a newline, and use LF instead of CRLF;
            # this allows us to use regex matches easier to modify these files.
            if(NOT "${contents}" MATCHES "\n$")
                string(APPEND contents "\n")
            endif()
            string(REPLACE "\r\n" "\n" contents "${contents}")

            string(REPLACE "${CURRENT_PACKAGES_DIR}" [[${prefix}]] contents "${contents}")
            string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${prefix}]] contents "${contents}")
            string(REPLACE "${unix_packages_dir}" [[${prefix}]] contents "${contents}")
            string(REPLACE "${unix_installed_dir}" [[${prefix}]] contents "${contents}")

            string(REGEX REPLACE "(^|\n) *prefix[\t ]*=[^\n]*" "" contents "${contents}")
            if("${config}" STREQUAL "DEBUG")
                # prefix points at the debug subfolder
                string(REPLACE [[${prefix}/debug]] [[${prefix}]] contents "${contents}")
                string(REPLACE [[${prefix}/include]] [[${prefix}/../include]] contents "${contents}")
                string(REPLACE [[${prefix}/share]] [[${prefix}/../share]] contents "${contents}")
            endif()
            # quote -L, -I, and -l paths starting with `${blah}`
            string(REGEX REPLACE " -([LIl])(\\\${[^}]*}[^ \n\t]*)" [[ -\1"\2"]] contents "${contents}")
            # This section fuses XYZ.private and XYZ according to VCPKG_LIBRARY_LINKAGE
            #
            # Pkgconfig searches Requires.private transitively for Cflags in the dynamic case,
            # which prevents us from removing it.
            #
            # Once this transformation is complete, users of vcpkg should never need to pass
            # --static.
            if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
                # how this works:
                # we want to transform:
                #   Libs: $1
                #   Libs.private: $2
                # into
                #    Libs: $1 $2
                # and the same thing for Requires and Requires.private

                foreach(item IN ITEMS "Libs" "Requires" "Cflags")
                    set(line "")
                    if("${contents}" MATCHES "(^|\n)${item}: *([^\n]*)")
                        string(APPEND line " ${CMAKE_MATCH_2}")
                    endif()
                    if("${contents}" MATCHES "(^|\n)${item}\\.private: *([^\n]*)")
                        string(APPEND line " ${CMAKE_MATCH_2}")
                    endif()

                    string(REGEX REPLACE "(^|\n)${item}(\\.private)?:[^\n]*\n" [[\1]] contents "${contents}")
                    if(NOT "${line}" STREQUAL "")
                        string(APPEND contents "${item}:${line}\n")
                    endif()
                endforeach()
            endif()
            file(WRITE "${file}" "prefix=\${pcfiledir}/${relative_pc_path}\n${contents}")
        endforeach()

        if(NOT arg_SKIP_CHECK) # The check can only run after all files have been corrected!
            vcpkg_find_acquire_program(PKGCONFIG)
            debug_message("Using pkg-config from: ${PKGCONFIG}")
            foreach(file IN LISTS "arg_${config}_FILES")
                z_vcpkg_fixup_pkgconfig_check_files("${file}" "${config}")
            endforeach()
        endif()
    endforeach()
    debug_message("Fixing pkgconfig --- finished")

    set(Z_VCPKG_FIXUP_PKGCONFIG_CALLED TRUE CACHE INTERNAL "See below" FORCE)
    # Variable to check if this function has been called!
    # Theoreotically vcpkg could look for *.pc files and automatically call this function
    # or check if this function has been called if *.pc files are detected.
    # The same is true for vcpkg_fixup_cmake_targets
endfunction()
