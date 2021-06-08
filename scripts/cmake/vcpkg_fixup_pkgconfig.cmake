#[===[.md:
# vcpkg_fixup_pkgconfig

Fix common paths in *.pc files and make everything relative to $(prefix).
Additionally, on static triplets, private entries are merged with their non-private counterparts,
allowing pkg-config to be called without the ``--static`` flag.
Note that vcpkg is designed to never have to call pkg-config with the ``--static`` flag,
since a consumer cannot know if a dependent library has been built statically or not.

## Usage
```cmake
vcpkg_fixup_pkgconfig(
    [RELEASE_FILES <PATHS>...]
    [DEBUG_FILES <PATHS>...]
    [SKIP_CHECK]
)
```

## Parameters
### RELEASE_FILES
Specifies a list of files to apply the fixes for release paths.
Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR} without ${CURRENT_PACKAGES_DIR}/debug/

### DEBUG_FILES
Specifies a list of files to apply the fixes for debug paths.
Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR}/debug/

### SKIP_CHECK
Skips the library checks in vcpkg_fixup_pkgconfig. Only use if the script itself has unhandled cases.

### SYSTEM_PACKAGES (deprecated)
This argument has been deprecated and has no effect.

### SYSTEM_LIBRARIES (deprecated)
This argument has been deprecated and has no effect.

### IGNORE_FLAGS (deprecated)
This argument has been deprecated and has no effect.

## Notes
Still work in progress. If there are more cases which can be handled here feel free to add them

## Examples

* [brotli](https://github.com/Microsoft/vcpkg/blob/master/ports/brotli/portfile.cmake)
#]===]

function(vcpkg_fixup_pkgconfig_check_files pkg_cfg_cmd _file _config)
    set(PATH_SUFFIX_DEBUG /debug)
    set(PATH_SUFFIX_RELEASE)
    set(PKGCONFIG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
    set(PKGCONFIG_INSTALLED_SHARE_DIR "${CURRENT_INSTALLED_DIR}/share/pkgconfig")
    set(PKGCONFIG_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
    set(PKGCONFIG_PACKAGES_SHARE_DIR "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

    if(DEFINED ENV{PKG_CONFIG_PATH})
        set(BACKUP_ENV_PKG_CONFIG_PATH "$ENV{PKG_CONFIG_PATH}")
    else()
        unset(BACKUP_ENV_PKG_CONFIG_PATH)
    endif()
    if(DEFINED ENV{PKG_CONFIG_PATH} AND NOT ENV{PKG_CONFIG_PATH} STREQUAL "")
        set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PKG_CONFIG_PATH}")
    else()
        set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_SHARE_DIR}")
    endif()

    # First make sure everything is ok with the package and its deps
    get_filename_component(_package_name "${_file}" NAME_WLE)
    debug_message("Checking package (${_config}): ${_package_name}")
    execute_process(COMMAND "${pkg_cfg_cmd}" --print-errors --exists ${_package_name}
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                    RESULT_VARIABLE _pkg_error_var
                    OUTPUT_VARIABLE _pkg_output
                    ERROR_VARIABLE  _pkg_error_out
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE
                    )
    if(NOT _pkg_error_var EQUAL 0)
        message(STATUS "pkg_cfg_cmd call with:${pkg_cfg_cmd} --exists ${_package_name} failed")
        message(STATUS "ENV{PKG_CONFIG_PATH}:$ENV{PKG_CONFIG_PATH}")
        message(STATUS "pkg-config call failed with error code:${_pkg_error_var}")
        message(STATUS "pkg-config output:${_pkg_output}")
        message(FATAL_ERROR "pkg-config error output:${_pkg_error_out}")
    else()
        debug_message("pkg-config returned:${_pkg_error_var}")
        debug_message("pkg-config output:${_pkg_output}")
        debug_message("pkg-config error output:${_pkg_error_out}")
    endif()
    if(DEFINED BACKUP_ENV_PKG_CONFIG_PATH)
        set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH}")
    else()
        unset(ENV{PKG_CONFIG_PATH})
    endif()
endfunction()

function(vcpkg_fixup_pkgconfig)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _vfpkg "SKIP_CHECK" "" "RELEASE_FILES;DEBUG_FILES;SYSTEM_LIBRARIES;SYSTEM_PACKAGES;IGNORE_FLAGS")

    if(_vfpkg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_pkgconfig() was passed extra arguments: ${_vfct_UNPARSED_ARGUMENTS}")
    endif()

    if((DEFINED _vfpkg_RELEASE_FILES AND NOT DEFINED _vfpkg_DEBUG_FILES) OR (NOT DEFINED _vfpkg_RELEASE_FILES AND DEFINED _vfpkg_DEBUG_FILES))
        message(FATAL_ERROR "vcpkg_fixup_pkgconfig() requires both or neither of DEBUG_FILES and RELEASE_FILES")
    endif()

    if(NOT DEFINED _vfpkg_RELEASE_FILES)
        file(GLOB_RECURSE _vfpkg_RELEASE_FILES "${CURRENT_PACKAGES_DIR}/**/*.pc")
        file(GLOB_RECURSE _vfpkg_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/**/*.pc")
        if(_vfpkg_DEBUG_FILES)
            list(REMOVE_ITEM _vfpkg_RELEASE_FILES ${_vfpkg_DEBUG_FILES})
        endif()
    endif()

    vcpkg_find_acquire_program(PKGCONFIG)
    debug_message("Using pkg-config from: ${PKGCONFIG}")

    #Absolute Unix like paths 
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}")
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}")

    foreach(CONFIG RELEASE DEBUG)
        debug_message("${CONFIG} Files: ${_vfpkg_${CONFIG}_FILES}")
        if(VCPKG_BUILD_TYPE STREQUAL "debug" AND CONFIG STREQUAL "RELEASE")
            continue()
        endif()
        if(VCPKG_BUILD_TYPE STREQUAL "release" AND CONFIG STREQUAL "DEBUG")
            continue()
        endif()
        foreach(_file ${_vfpkg_${CONFIG}_FILES})
            message(STATUS "Fixing pkgconfig file: ${_file}")
            get_filename_component(PKG_LIB_SEARCH_PATH "${_file}" DIRECTORY)
            if(CONFIG STREQUAL "DEBUG")
                file(RELATIVE_PATH RELATIVE_PC_PATH "${PKG_LIB_SEARCH_PATH}" "${CURRENT_PACKAGES_DIR}/debug/")
            else()
                file(RELATIVE_PATH RELATIVE_PC_PATH "${PKG_LIB_SEARCH_PATH}" "${CURRENT_PACKAGES_DIR}")
            endif()
            # strip trailing slash
            string(REGEX REPLACE "/$" "" RELATIVE_PC_PATH "${RELATIVE_PC_PATH}")
            #Correct *.pc file
            file(READ "${_file}" _contents)
            string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
            string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
            string(REPLACE "${_VCPKG_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
            string(REPLACE "${_VCPKG_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
            string(REGEX REPLACE "(^|\n)prefix[\t ]*=[^\n]*" "" _contents "${_contents}")
            if(CONFIG STREQUAL "DEBUG")
                string(REPLACE "}/debug" "}" _contents "${_contents}")
                # Prefix points at the debug subfolder
                string(REPLACE "\${prefix}/include" "\${prefix}/../include" _contents "${_contents}")
                string(REPLACE "\${prefix}/share" "\${prefix}/../share" _contents "${_contents}")
            endif()
            string(REGEX REPLACE " -L(\\\${[^}]*}[^ \n\t]*)" " -L\"\\1\"" _contents "${_contents}")
            string(REGEX REPLACE " -I(\\\${[^}]*}[^ \n\t]*)" " -I\"\\1\"" _contents "${_contents}")
            string(REGEX REPLACE " -l(\\\${[^}]*}[^ \n\t]*)" " -l\"\\1\"" _contents "${_contents}")
            # This section fuses XYZ.private and XYZ according to VCPKG_LIBRARY_LINKAGE
            #
            # Pkgconfig searches Requires.private transitively for Cflags in the dynamic case,
            # which prevents us from removing it.
            #
            # Once this transformation is complete, users of vcpkg should never need to pass
            # --static.
            if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
                # Libs comes before Libs.private
                string(REGEX REPLACE "(^|\n)(Libs: *[^\n]*)(.*)\nLibs.private:( *[^\n]*)" "\\1\\2\\4\\3" _contents "${_contents}")
                # Libs.private comes before Libs
                string(REGEX REPLACE "(^|\n)Libs.private:( *[^\n]*)(.*\nLibs: *[^\n]*)" "\\3\\2" _contents "${_contents}")
                # Only Libs.private
                string(REGEX REPLACE "(^|\n)Libs.private: *" "\\1Libs: " _contents "${_contents}")
                # Requires comes before Requires.private
                string(REGEX REPLACE "(^|\n)(Requires: *[^\n]*)(.*)\nRequires.private:( *[^\n]*)" "\\1\\2\\4\\3" _contents "${_contents}")
                # Requires.private comes before Requires
                string(REGEX REPLACE "(^|\n)Requires.private:( *[^\n]*)(.*\nRequires: *[^\n]*)" "\\3\\2" _contents "${_contents}")
                # Only Requires.private
                string(REGEX REPLACE "(^|\n)Requires.private: *" "\\1Requires: " _contents "${_contents}")
            endif()
            file(WRITE "${_file}" "prefix=\${pcfiledir}/${RELATIVE_PC_PATH}\n${_contents}")
            unset(PKG_LIB_SEARCH_PATH)
        endforeach()

        if(NOT _vfpkg_SKIP_CHECK) # The check can only run after all files have been corrected!
            foreach(_file ${_vfpkg_${CONFIG}_FILES})
                vcpkg_fixup_pkgconfig_check_files("${PKGCONFIG}" "${_file}" "${CONFIG}")
            endforeach()
        endif()
    endforeach()
    debug_message("Fixing pkgconfig --- finished")

    set(VCPKG_FIXUP_PKGCONFIG_CALLED TRUE CACHE INTERNAL "See below" FORCE)
    # Variable to check if this function has been called!
    # Theoreotically vcpkg could look for *.pc files and automatically call this function
    # or check if this function has been called if *.pc files are detected.
    # The same is true for vcpkg_fixup_cmake_targets
endfunction()
