#[===[.md:
# vcpkg_find_acquire_program

Download or find a well-known tool.

## Usage
```cmake
vcpkg_find_acquire_program(<VAR>)
```
## Parameters
### VAR
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
    message(FATAL_ERROR "Internal error: invalid program data for program ${VAR} - no data found")
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

function(vcpkg_find_acquire_program VAR)
  set(EXPANDED_VAR ${${VAR}})
  if(EXPANDED_VAR)
    return()
  endif()

  unset(NOEXTRACT)
  unset(final_program_name)
  unset(SUBDIR)
  unset(PROG_PATH_SUBDIR)
  unset(REQUIRED_INTERPRETER)
  unset(_vfa_SUPPORTED)
  unset(POST_INSTALL_COMMAND)
  unset(PATHS)

  string(
    JSON program_data
    ERROR_VARIABLE program_data_error
    GET
      "${Z_VCPKG_FIND_ACQUIRE_PROGRAM_DATA}"
      "${VAR}"
  )
  if(NOT "${program_data_error}" STREQUAL "NOTFOUND")
    message(WARNING "Error finding program ${VAR}: ${program_data_error}")
  endif()

  if("${program_data_error}" STREQUAL "NOTFOUND")
    z_vcpkg_find_acquire_program_set_variables("${program_data}" ignore)
  else()
    message(FATAL_ERROR "unknown tool ${VAR} -- unable to acquire.")
  endif()

  if(DEFINED envvar AND DEFINED ENV{${envvar}})
    debug_message(STATUS "${envvar} found in ENV! Using $ENV{${envvar}}")
    set("${VAR}" "${ENV{${envvar}}" PARENT_SCOPE)
    return()
  endif()

  macro(do_version_check)
    if(VERSION_CMD)
        vcpkg_execute_in_download_mode(
            COMMAND ${${VAR}} ${VERSION_CMD}
            WORKING_DIRECTORY ${VCPKG_ROOT_DIR}
            OUTPUT_VARIABLE PROGRAM_VERSION_OUTPUT
        )
        string(STRIP "${PROGRAM_VERSION_OUTPUT}" PROGRAM_VERSION_OUTPUT)
        #TODO: REGEX MATCH case for more complex cases!
        if(NOT PROGRAM_VERSION_OUTPUT VERSION_GREATER_EQUAL PROGRAM_VERSION)
            message(STATUS "Found ${PROGNAME}('${PROGRAM_VERSION_OUTPUT}') but at least version ${PROGRAM_VERSION} is required! Trying to use internal version if possible!")
            unset(${VAR})
        else()
            message(STATUS "Found external ${PROGNAME}('${PROGRAM_VERSION_OUTPUT}').")
        endif()
    endif()
  endmacro()

  macro(do_find)
    if(NOT DEFINED REQUIRED_INTERPRETER)
      find_program(${VAR} ${PROGNAME} PATHS ${PATHS} NO_DEFAULT_PATH)
      if(NOT ${VAR})
        find_program(${VAR} ${PROGNAME})
        if(${VAR} AND NOT PROGRAM_VERSION_CHECKED)
            do_version_check()
            set(PROGRAM_VERSION_CHECKED ON)
        elseif(PROGRAM_VERSION_CHECKED)
            message(FATAL_ERROR "Unable to find ${PROGNAME} with min version of ${PROGRAM_VERSION}")
        endif()
      endif()
    else()
      vcpkg_find_acquire_program(${REQUIRED_INTERPRETER})
      find_file(SCRIPT_${VAR} NAMES ${SCRIPTNAME} PATHS ${PATHS} NO_DEFAULT_PATH)
      if(NOT SCRIPT_${VAR})
        find_file(SCRIPT_${VAR} NAMES ${SCRIPTNAME})
        if(SCRIPT_${VAR} AND NOT PROGRAM_VERSION_CHECKED)
            set(${VAR} ${${REQUIRED_INTERPRETER}} ${SCRIPT_${VAR}})
            do_version_check()
            set(PROGRAM_VERSION_CHECKED ON)
            if(NOT ${VAR})
                unset(SCRIPT_${VAR} CACHE)
            endif()
        elseif(PROGRAM_VERSION_CHECKED)
            message(FATAL_ERROR "Unable to find ${PROGNAME} with min version of ${PROGRAM_VERSION}")
        endif()
      endif()
      if(SCRIPT_${VAR})
        set(${VAR} ${${REQUIRED_INTERPRETER}} ${SCRIPT_${VAR}})
      endif()
    endif()
  endmacro()

  if(NOT DEFINED PROG_PATH_SUBDIR)
    set(PROG_PATH_SUBDIR "${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}")
  endif()
  if(DEFINED SUBDIR)
    list(APPEND PATHS ${PROG_PATH_SUBDIR})
  endif()
  if("${PROG_PATH_SUBDIR}" MATCHES [[^(.*)[/\\]$]])
    # remove trailing slash, which may turn into a trailing `\` which CMake _does not like_
    set(PROG_PATH_SUBDIR "${CMAKE_MATCH_1}")
  endif()

  do_find()
  if(NOT ${VAR})
    if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows" AND NOT _vfa_SUPPORTED)
      set(EXAMPLE ".")
      if(DEFINED BREW_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        set(EXAMPLE ":\n    brew install ${BREW_PACKAGE_NAME}")
      elseif(DEFINED APT_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        set(EXAMPLE ":\n    sudo apt-get install ${APT_PACKAGE_NAME}")
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
        vcpkg_list(APPEND PATHS ${sourceforge_paths_tmp})
      else()
        vcpkg_list(APPEND PATHS "${sfpath}")
      endif()
    elseif(DEFINED MSYS_ARGS AND VCPKG_HOST_IS_WINDOWS)
      vcpkg_acquire_msys(msys_root ${MSYS_ARGS})

      if(DEFINED MSYS_PATHS)
        string(REPLACE "$" "${msys_root}" msys_paths_tmp "${MSYS_PATHS}")
        vcpkg_list(APPEND PATHS ${msys_paths_tmp})
      endif()
    else()
      vcpkg_download_distfile(ARCHIVE_PATH
          URLS ${URL}
          SHA512 ${HASH}
          FILENAME ${ARCHIVE}
      )

      file(MAKE_DIRECTORY ${PROG_PATH_SUBDIR})
      if(DEFINED NOEXTRACT)
        if(DEFINED final_program_name)
          file(INSTALL ${ARCHIVE_PATH}
            DESTINATION ${PROG_PATH_SUBDIR}
            RENAME "${final_program_name}"
            FILE_PERMISSIONS
              OWNER_READ OWNER_WRITE OWNER_EXECUTE
              GROUP_READ GROUP_EXECUTE
              WORLD_READ WORLD_EXECUTE
          )
        else()
          file(COPY ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR} FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
        endif()
      else()
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
    endif()

    if(DEFINED POST_INSTALL_COMMAND)
      vcpkg_execute_required_process(
        ALLOW_IN_DOWNLOAD_MODE
        COMMAND ${POST_INSTALL_COMMAND}
        WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
        LOGNAME ${VAR}-tool-post-install
      )
    endif()
    unset(${VAR} CACHE)
    do_find()
    if(NOT ${VAR})
        message(FATAL_ERROR "Unable to find ${VAR}")
    endif()
  endif()

  set(${VAR} "${${VAR}}" PARENT_SCOPE)
endfunction()
