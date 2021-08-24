#[===[.md:
# vcpkg_find_acquire_program

Download or find a well-known tool.

## Usage
```cmake
vcpkg_find_acquire_program(<program>)
```
## Parameters
### program
This variable specifies both the program to be acquired as well as the out parameter that will be set to the path of the program executable.

## Notes
The current list of programs includes:

* 7Z
* ARIA2 (Downloader)
* BISON
* CLANG
* DARK
* DOXYGEN
* FLEX
* GASPREPROCESSOR
* GPERF
* PERL
* PYTHON2
* PYTHON3
* GIT
* GN
* GO
* JOM
* MESON
* NASM
* NINJA
* NUGET
* SCONS
* SWIG
* YASM

Note that msys2 has a dedicated helper function: [`vcpkg_acquire_msys`](vcpkg_acquire_msys.md).

## Examples

* [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
* [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
* [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)
#]===]

file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg_find_acquire_program_data.json" Z_VCPKG_FIND_ACQUIRE_PROGRAM_DATA)

function(z_vcpkg_find_acquire_program_set_variables variables_array out_var_out_variables)
    vcpkg_list(SET out_variables)

    string(JSON variables_array_length LENGTH "${variables_array}")
    if("${variables_array_length}" EQUAL "0")
        message(FATAL_ERROR "Internal error: invalid program data for program ${program} - no data found")
    endif()

    math(EXPR variables_array_last_index "${variables_array_length} - 1")
    foreach(index RANGE 0 "${variables_array_last_index}")
        string(JSON key_name MEMBER "${variables_array}" "${index}" "0")

        if("${key_name}" STREQUAL "$comment")
        elseif("${key_name}" STREQUAL "$if")
            string(JSON host_os ERROR_VARIABLE host_os_err GET "${variables_array}" "${index}" "$if" "$host_os")
            string(JSON host_arch ERROR_VARIABLE host_arch_err GET "${variables_array}" "${index}" "$if" "$host_architecture")

            set(should_do_else_branch OFF)
            if("${host_os_err}" STREQUAL "NOTFOUND")
                if(NOT "${VCPKG_HOST_IS_${host_os}}")
                    set(should_do_else_branch ON)
                endif()
            endif()
            if("${host_arch_err}" STREQUAL "NOTFOUND")
                if(NOT "${VCPKG_HOST_ARCHITECTURE}" STREQUAL "${host_arch}")
                    set(should_do_else_branch ON)
                endif()
            endif()

            if(should_do_else_branch)
                string(JSON new_variables_array ERROR_VARIABLE branch_err GET "${variables_array}" "${index}" "$if" "$else")
            else()
                string(JSON new_variables_array ERROR_VARIABLE branch_err GET "${variables_array}" "${index}" "$if" "$then")
            endif()

            if("${branch_err}" STREQUAL "NOTFOUND")
                z_vcpkg_find_acquire_program_set_variables("${new_variables_array}" vars_set_in_subcall)
                vcpkg_list(APPEND out_variables ${vars_set_in_subcall})
            endif()
        elseif(key_name MATCHES [[^\$]])
            message(FATAL_ERROR "Unsupported special key name ${key_name} - supported special key names: $if, $comment")
        else()
            string(JSON key_type TYPE "${variables_array}" "${index}" "${key_name}")
            string(JSON key_value GET "${variables_array}" "${index}" "${key_name}")

            # join the elements if the key_type is array
            if("${key_type}" STREQUAL "ARRAY")
                string(JSON array_length LENGTH "${key_value}")
                if("${array_length}" EQUAL "0")
                    set(key_value "")
                else()
                    math(EXPR array_last_index "${array_length} - 1")
                    vcpkg_list(SET key_value_tmp)
                    foreach(key_value_index RANGE 0 "${array_last_index}")
                        string(JSON key_value_element GET "${key_value}" "${key_value_index}")
                        vcpkg_list(APPEND key_value_tmp "${key_value_element}")
                    endforeach()
                    set(key_value "${key_value_tmp}")
                endif()
            endif()

            string(CONFIGURE "${key_value}" "${key_name}" @ONLY)
            vcpkg_list(APPEND out_variables "${key_name}")
        endif()
    endforeach()

    foreach(var IN LISTS out_variables)
        message(STATUS "setting ${var} to ${${var}}")
        set("${var}" "${${var}}" PARENT_SCOPE)
    endforeach()
    set("${out_var_out_variables}" "${out_variables}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_find_acquire_program_version_check program)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "VERSION_COMMAND;VERSION" "")
    vcpkg_execute_in_download_mode(
        COMMAND ${${program}} ${arg_VERSION_COMMAND}
        WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
        OUTPUT_VARIABLE program_version_output
    )
    string(STRIP "${program_version_output}" program_version_output)
    #TODO: REGEX MATCH case for more complex cases!
    if(NOT "${program_version_output}" VERSION_GREATER_EQUAL "${arg_VERSION}")
        message(STATUS "Found ${program_name}('${program_version_output}'), but at least version ${arg_VERSION} is required! Trying to use internal version if possible!")
        unset("${program}" PARENT_SCOPE)
    else()
        message(STATUS "Found external ${program}('${program_version_output}').")
    endif()
endfunction()

function(vcpkg_find_acquire_program program)
    if("${${program}}")
        return()
    endif()

    set(extract_download ON)
    set(final_program_name "")
    set(subdirectory "")
    set(download_supported_on_unix OFF)
    set(required_interpreter "")
    set(envvar "")
    vcpkg_list(SET version_command)
    vcpkg_list(SET post_install_command)
    vcpkg_list(SET paths)

    string(
        JSON program_data
        ERROR_VARIABLE program_data_error
        GET
            "${Z_VCPKG_FIND_ACQUIRE_PROGRAM_DATA}"
            "${program}"
    )
    if(NOT "${program_data_error}" STREQUAL "NOTFOUND")
        message(WARNING "Error finding program ${program}: ${program_data_error}")
    endif()

    if("${program_data_error}" STREQUAL "NOTFOUND")
        z_vcpkg_find_acquire_program_set_variables("${program_data}" ignore)
    else()
        message(FATAL_ERROR "unknown tool ${program} -- unable to acquire.")
    endif()

    if(NOT "${envvar}" STREQUAL "" AND DEFINED ENV{${envvar}})
        debug_message(STATUS "${envvar} found in ENV! Using $ENV{${envvar}}")
        set("${program}" "$ENV{${envvar}}" PARENT_SCOPE)
        return()
    endif()

    macro(do_find)
        if(NOT "${required_interpreter}" STREQUAL "")
            vcpkg_find_acquire_program("${required_interpreter}")
            find_file(script NAMES ${SCRIPTNAME} PATHS ${paths} NO_DEFAULT_PATH)
            if(NOT script)
                find_file(script NAMES ${SCRIPTNAME})
                if(SCRIPT_${program} AND NOT PROGRAM_VERSION_CHECKED)
                    set(${program} ${${required_interpreter}} ${SCRIPT_${program}})
                    if(NOT "${version_command}" STREQUAL "")
                        z_vcpkg_find_acquire_program_version_check("${program}"
                            VERSION_COMMAND "${version_command}"
                            REQUIRED_VERSION "${PROGRAM_VERSION}"
                        )
                    endif()
                    set(PROGRAM_VERSION_CHECKED ON)
                    if(NOT ${program})
                        unset(SCRIPT_${program} CACHE)
                    endif()
                elseif(PROGRAM_VERSION_CHECKED)
                    message(FATAL_ERROR "Unable to find ${PROGNAME} with min version of ${PROGRAM_VERSION}")
                endif()
            endif()
            if(SCRIPT_${program})
                set(${program} ${${required_interpreter}} ${SCRIPT_${program}})
            endif()
        else()
            find_program(${program} ${PROGNAME} PATHS ${paths} NO_DEFAULT_PATH)
            if(NOT ${program})
                find_program(${program} ${PROGNAME})
                if(${program} AND NOT PROGRAM_VERSION_CHECKED)
                    if(NOT "${version_command}" STREQUAL "")
                        z_vcpkg_find_acquire_program_version_check("${program}"
                            VERSION_COMMAND "${version_command}"
                            REQUIRED_VERSION "${PROGRAM_VERSION}"
                        )
                    endif()
                    set(PROGRAM_VERSION_CHECKED ON)
                elseif(PROGRAM_VERSION_CHECKED)
                    message(FATAL_ERROR "Unable to find ${PROGNAME} with min version of ${PROGRAM_VERSION}")
                endif()
            endif()
        endif()
    endmacro()

    if(NOT "${subdirectory}" STREQUAL "")
        set(PROG_PATH_SUBDIR "${DOWNLOADS}/tools/${PROGNAME}/${subdirectory}")
        vcpkg_list(APPEND paths ${PROG_PATH_SUBDIR})
    endif()
    if("${PROG_PATH_SUBDIR}" MATCHES [[^(.*)[/\\]$]])
        # remove trailing slash, which may turn into a trailing `\` which CMake _does not like_
        set(PROG_PATH_SUBDIR "${CMAKE_MATCH_1}")
    endif()

    do_find()
    if(NOT ${program})
        if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows" AND NOT _vfa_SUPPORTED)
            set(EXAMPLE ".")
            if(DEFINED BREW_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
                set(EXAMPLE ":\n        brew install ${BREW_PACKAGE_NAME}")
            elseif(DEFINED APT_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
                set(EXAMPLE ":\n        sudo apt-get install ${APT_PACKAGE_NAME}")
            endif()
            message(FATAL_ERROR "Could not find ${PROGNAME}. Please install it via your package manager${EXAMPLE}")
        endif()

        if(DEFINED SOURCEFORGE_ARGS)
            # Locally change editable to suppress re-extraction each time
            set(_VCPKG_EDITABLE 1)
            vcpkg_from_sourceforge(OUT_SOURCE_PATH sfpath ${SOURCEFORGE_ARGS})
            unset(_VCPKG_EDITABLE)

            if(DEFINED SOURCEFORGE_PATHS)
                string(REPLACE "$" "${sfpath}" sourceforge_paths_tmp "${SOURCEFORGE_PATHS}")
                vcpkg_list(APPEND paths ${sourceforge_paths_tmp})
            else()
                vcpkg_list(APPEND paths "${sfpath}")
            endif()
        elseif(DEFINED MSYS_ARGS AND VCPKG_HOST_IS_WINDOWS)
            vcpkg_acquire_msys(msys_root ${MSYS_ARGS})

            if(DEFINED MSYS_PATHS)
                string(REPLACE "$" "${msys_root}" msys_paths_tmp "${MSYS_PATHS}")
                vcpkg_list(APPEND paths ${msys_paths_tmp})
            endif()
        else()
            vcpkg_download_distfile(ARCHIVE_PATH
                    URLS ${URL}
                    SHA512 ${HASH}
                    FILENAME ${ARCHIVE}
            )

            file(MAKE_DIRECTORY ${PROG_PATH_SUBDIR})
            if(extract_download)
                get_filename_component(ARCHIVE_EXTENSION ${ARCHIVE} LAST_EXT)
                string(TOLOWER "${ARCHIVE_EXTENSION}" ARCHIVE_EXTENSION)
                if(ARCHIVE_EXTENSION STREQUAL ".msi")
                    file(TO_NATIVE_PATH "${ARCHIVE_PATH}" ARCHIVE_NATIVE_PATH)
                    file(TO_NATIVE_PATH "${PROG_PATH_SUBDIR}" DESTINATION_NATIVE_PATH)
                    vcpkg_execute_in_download_mode(
                        COMMAND msiexec /a ${ARCHIVE_NATIVE_PATH} /qn TARGETDIR=${DESTINATION_NATIVE_PATH}
                        WORKING_DIRECTORY ${DOWNLOADS}
                    )
                elseif("${ARCHIVE_PATH}" MATCHES ".7z.exe$")
                    vcpkg_find_acquire_program(7Z)
                    vcpkg_execute_in_download_mode(
                        COMMAND ${7Z} x "${ARCHIVE_PATH}" "-o${PROG_PATH_SUBDIR}" -y -bso0 -bsp0
                        WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
                    )
                else()
                    vcpkg_execute_in_download_mode(
                        COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
                        WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
                    )
                endif()
            endif()

            if("${final_program_name}" STREQUAL "")
                file(COPY ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR} FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
            else()
                file(INSTALL ${ARCHIVE_PATH}
                    DESTINATION ${PROG_PATH_SUBDIR}
                    RENAME "${final_program_name}"
                    FILE_PERMISSIONS
                        OWNER_READ OWNER_WRITE OWNER_EXECUTE
                        GROUP_READ GROUP_EXECUTE
                        WORLD_READ WORLD_EXECUTE
                )
            endif()
        endif()

        if(NOT "${post_install_command}" STREQUAL "")
            vcpkg_execute_required_process(
                ALLOW_IN_DOWNLOAD_MODE
                COMMAND ${post_install_command}
                WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
                LOGNAME ${program}-tool-post-install
            )
        endif()
        unset(${program} CACHE)
        do_find()
        if(NOT ${program})
                message(FATAL_ERROR "Unable to find ${program}")
        endif()
    endif()

    set(${program} "${${program}}" PARENT_SCOPE)
endfunction()
