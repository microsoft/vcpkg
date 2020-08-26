## # vcpkg_fixup_pkgconfig
##
## Fix common paths in *.pc files and make everything relativ to $(prefix)
##
## ## Usage
## ```cmake
## vcpkg_fixup_pkgconfig(
##     [RELEASE_FILES <PATHS>...]
##     [DEBUG_FILES <PATHS>...]
##     [SYSTEM_LIBRARIES <NAMES>...]
##     [IGNORE_FLAGS <FLAGS>]
##     [SKIP_CHECK]
## )
## ```
##
## ## Parameters
## ### RELEASE_FILES
## Specifies a list of files to apply the fixes for release paths.
## Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR} without ${CURRENT_PACKAGES_DIR}/debug/
##
## ### DEBUG_FILES
## Specifies a list of files to apply the fixes for debug paths.
## Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR}/debug/
##
## ### SYSTEM_LIBRARIES
## If the *.pc file contains system libraries outside vcpkg these need to be listed here.
## VCPKG checks every -l flag for the existence of the required library within vcpkg.
##
## ### IGNORE_FLAGS
## If the *.pc file contains flags in the lib field which are not libraries. These can be listed here
##
## ### SKIP_CHECK
## Skips the library checks in vcpkg_fixup_pkgconfig. Only use if the script itself has unhandled cases. 
##
## ## Notes
## Still work in progress. If there are more cases which can be handled here feel free to add them
##
## ## Examples
## Just call vcpkg_fixup_pkgconfig() after any install step which installs *.pc files.

include(vcpkg_escape_regex_control_characters)
function(vcpkg_fixup_pkgconfig_check_files pkg_cfg_cmd _file _config _system_libs _ignore_flags)
    set(PATH_SUFFIX_DEBUG /debug)
    set(PATH_SUFFIX_RELEASE)
    set(PKGCONFIG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
    set(PKGCONFIG_INSTALLED_SHARE_DIR "${CURRENT_INSTALLED_DIR}/share/pkgconfig")
    set(PKGCONFIG_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
    set(PKGCONFIG_PACKAGES_SHARE_DIR "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

    set(BACKUP_ENV_PKG_CONFIG_PATH "$ENV{PKG_CONFIG_PATH}")
    if(ENV{PKG_CONFIG_PATH})
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

    # Get all required libs. --static means we get all libraries required for static linkage 
    # which is the worst case and includes the case without --static
    # This retests already tested *.pc files since pkg-config will recursivly search for
    # required packages and add there link flags to the one being tested
    # as such NOT_STATIC_PKGCONFIG might be used to deactivate the --static arg to pkg-config

    execute_process(COMMAND "${pkg_cfg_cmd}" --print-errors ${PKGCONFIG_STATIC} --libs ${_package_name}
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                    RESULT_VARIABLE _pkg_error_var
                    OUTPUT_VARIABLE _pkg_libs_output
                    ERROR_VARIABLE  _pkg_error_out
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE
                    )
    if(NOT _pkg_error_var EQUAL 0)
        message(STATUS "pkg_cfg_cmd call with:${pkg_cfg_cmd} --libs ${_package_name} failed")
        message(STATUS "pkg-config call failed with error code:${_pkg_error_var}")
        message(STATUS "pkg-config output:${_pkg_libs_output}")
        message(FATAL_ERROR "pkg-config error output:${_pkg_error_out}")
    else()
        debug_message("pkg-config returned:${_pkg_error_var}")
        debug_message("pkg-config output:${_pkg_libs_output}")
        debug_message("pkg-config error output:${_pkg_error_out}")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND CMAKE_FIND_LIBRARY_SUFFIXES .lib .dll.a .a)
    endif()
    set(SEARCH_PATHS)
    string(REGEX MATCHALL "([^ \t\\\\]+|\\\\.)+|\"([^\"\\\\]+|\\\\.)+\"" LIBS_ARGS "${_pkg_libs_output}")
    foreach(LIBS_ARG IN LISTS LIBS_ARGS)
        string(REGEX REPLACE "\\\\(.)" "\\1" LIBS_ARG "${LIBS_ARG}")
        debug_message("pkg-config processing '${LIBS_ARG}'")
        if(LIBS_ARG MATCHES "^-L(.*)")
            list(APPEND SEARCH_PATHS "${CMAKE_MATCH_1}")
        elseif(LIBS_ARG MATCHES "^-l(.*)")
            # Absolute paths
            if(IS_ABSOLUTE "${CMAKE_MATCH_1}" AND EXISTS "${CMAKE_MATCH_1}")
                continue()
            endif()
            # Explicitly allowed by system libs list
            if("${CMAKE_MATCH_1}" IN_LIST _system_libs)
                continue()
            endif()
            set(LIBNAME "${CMAKE_MATCH_1}")
            # Ensure existance in current packages and installed
            find_library("CHECK_LIB_${LIBNAME}_${_config}" NAMES "${LIBNAME}" PATHS ${SEARCH_PATHS} "${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_config}}/lib" NO_DEFAULT_PATH)
            if("${CHECK_LIB_${LIBNAME}_${_config}}" MATCHES "-NOTFOUND\$")
                message(FATAL_ERROR "find_library() failed with result: ${CHECK_LIB_${LIBNAME}_${_config}}\n    find_library(CHECK_LIB_${LIBNAME}_${_config} NAMES \"${LIBNAME}\" PATHS ${SEARCH_PATHS} \"${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_config}}/lib\" NO_DEFAULT_PATH)")
            else()
                debug_message("CHECK_LIB_${LIBNAME}_${_config}=${CHECK_LIB_${LIBNAME}_${_config}}")
            endif()
        endif()
    endforeach()

    set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH}")
endfunction()

function(vcpkg_fixup_pkgconfig)
    cmake_parse_arguments(_vfpkg "SKIP_CHECK;NOT_STATIC_PKGCONFIG" "" "RELEASE_FILES;DEBUG_FILES;SYSTEM_LIBRARIES;SYSTEM_PACKAGES;IGNORE_FLAGS" ${ARGN})

    # Note about SYSTEM_PACKAGES: pkg-config requires all packages mentioned in pc files to exists. Otherwise pkg-config will fail to find the pkg.
    # As such naming any SYSTEM_PACKAGES is damned to fail which is why it is not mentioned in the docs at the beginning.
    if(VCPKG_SYSTEM_LIBRARIES)
        list(APPEND _vfpkg_SYSTEM_LIBRARIES ${VCPKG_SYSTEM_LIBRARIES})
    endif()

    if(_vfpkg_NOT_STATIC_PKGCONFIG)
        set(PKGCONFIG_STATIC)
    else()
        set(PKGCONFIG_STATIC --static)
    endif()
    
    if(_vfpkg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_pkgconfig was passed extra arguments: ${_vfct_UNPARSED_ARGUMENTS}")
    endif()

    vcpkg_escape_regex_control_characters(_vfpkg_ESCAPED_CURRENT_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}")
    if(NOT _vfpkg_RELEASE_FILES)
        file(GLOB_RECURSE _vfpkg_RELEASE_FILES "${CURRENT_PACKAGES_DIR}/**/*.pc")
        list(FILTER _vfpkg_RELEASE_FILES EXCLUDE REGEX "${_vfpkg_ESCAPED_CURRENT_PACKAGES_DIR}/debug/")
    endif()

    if(NOT _vfpkg_DEBUG_FILES)
        file(GLOB_RECURSE _vfpkg_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/**/*.pc")
        list(FILTER _vfpkg_DEBUG_FILES INCLUDE REGEX "${_vfpkg_ESCAPED_CURRENT_PACKAGES_DIR}/debug/")
    endif()

    vcpkg_find_acquire_program(PKGCONFIG)
    debug_message("Using pkg-config from: ${PKGCONFIG}")

    #Absolute Unix like paths 
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}")
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}")

    debug_message("Release Files: ${_vfpkg_RELEASE_FILES}")
    foreach(_file ${_vfpkg_RELEASE_FILES})
        message(STATUS "Fixing pkgconfig file: ${_file}")
        get_filename_component(PKG_LIB_SEARCH_PATH "${_file}" DIRECTORY)
        file(RELATIVE_PATH RELATIVE_PC_PATH "${PKG_LIB_SEARCH_PATH}" "${CURRENT_PACKAGES_DIR}")
        string(REGEX REPLACE "/$" "" RELATIVE_PC_PATH "${RELATIVE_PC_PATH}")
        #Correct *.pc file
        file(READ "${_file}" _contents)
        string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${_VCPKG_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${_VCPKG_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        string(REGEX REPLACE "^prefix=(\")?(\\\\)?\\\${prefix}(\")?" "prefix=\${pcfiledir}/${RELATIVE_PC_PATH}" _contents "${_contents}") # make pc file relocatable
        string(REGEX REPLACE "[\n]prefix=(\")?(\\\\)?\\\${prefix}(\")?" "\nprefix=\${pcfiledir}/${RELATIVE_PC_PATH}" _contents "${_contents}") # make pc file relocatable
        string(REGEX REPLACE " -L(\\\${[^}]*}[^ \n\t]*)" " -L\"\\1\"" _contents "${_contents}")
        string(REGEX REPLACE " -I(\\\${[^}]*}[^ \n\t]*)" " -I\"\\1\"" _contents "${_contents}")
        string(REGEX REPLACE " -l(\\\${[^}]*}[^ \n\t]*)" " -l\"\\1\"" _contents "${_contents}")
        file(WRITE "${_file}" "${_contents}")
    endforeach()

    if(NOT _vfpkg_SKIP_CHECK) # The check can only run after all files have been corrected!
        foreach(_file ${_vfpkg_RELEASE_FILES})
            vcpkg_fixup_pkgconfig_check_files("${PKGCONFIG}" "${_file}" "RELEASE" "${_vfpkg_SYSTEM_LIBRARIES}" "${_vfpkg_IGNORE_FLAGS}")
        endforeach()
    endif()

    debug_message("Debug Files: ${_vfpkg_DEBUG_FILES}")
    foreach(_file ${_vfpkg_DEBUG_FILES})
        message(STATUS "Fixing pkgconfig file: ${_file}")
        get_filename_component(PKG_LIB_SEARCH_PATH "${_file}" DIRECTORY)
        file(RELATIVE_PATH RELATIVE_PC_PATH "${PKG_LIB_SEARCH_PATH}" "${CURRENT_PACKAGES_DIR}/debug/")
        string(REGEX REPLACE "/$" "" RELATIVE_PC_PATH "${RELATIVE_PC_PATH}")
        string(REGEX REPLACE "/pkgconfig/?" "" PKG_LIB_SEARCH_PATH "${PKG_LIB_SEARCH_PATH}")
        #Correct *.pc file
        file(READ "${_file}" _contents)
        string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${_VCPKG_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${_VCPKG_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "debug/include" "../include" _contents "${_contents}")
        string(REPLACE "\${prefix}/include" "\${prefix}/../include" _contents "${_contents}")
        string(REPLACE "debug/share" "../share" _contents "${_contents}")
        string(REPLACE "\${prefix}/share" "\${prefix}/../share" _contents "${_contents}")
        string(REPLACE "debug/lib" "lib" _contents "${_contents}") # the prefix will contain the debug keyword
        string(REGEX REPLACE "^prefix=(\")?(\\\\)?\\\${prefix}(/debug)?(\")?" "prefix=\${pcfiledir}/${RELATIVE_PC_PATH}" _contents "${_contents}") # make pc file relocatable
        string(REGEX REPLACE "[\n]prefix=(\")?(\\\\)?\\\${prefix}(/debug)?(\")?" "\nprefix=\${pcfiledir}/${RELATIVE_PC_PATH}" _contents "${_contents}") # make pc file relocatable
        string(REPLACE "\${prefix}/debug" "\${prefix}" _contents "${_contents}") # replace remaining debug paths if they exist. 
        string(REGEX REPLACE " -L(\\\${[^}]*}[^ \n\t]*)" " -L\"\\1\"" _contents "${_contents}")
        string(REGEX REPLACE " -I(\\\${[^}]*}[^ \n\t]*)" " -I\"\\1\"" _contents "${_contents}")
        string(REGEX REPLACE " -l(\\\${[^}]*}[^ \n\t]*)" " -l\"\\1\"" _contents "${_contents}")
        file(WRITE "${_file}" "${_contents}")
    endforeach()

    if(NOT _vfpkg_SKIP_CHECK) # The check can only run after all files have been corrected!
        foreach(_file ${_vfpkg_DEBUG_FILES})
            vcpkg_fixup_pkgconfig_check_files("${PKGCONFIG}" "${_file}" "DEBUG" "${_vfpkg_SYSTEM_LIBRARIES}" "${_vfpkg_IGNORE_FLAGS}")
        endforeach()
    endif()
    debug_message("Fixing pkgconfig --- finished")

    set(VCPKG_FIXUP_PKGCONFIG_CALLED TRUE CACHE INTERNAL "See below" FORCE)
    # Variable to check if this function has been called!
    # Theoreotically vcpkg could look for *.pc files and automatically call this function
    # or check if this function has been called if *.pc files are detected.
    # The same is true for vcpkg_fixup_cmake_targets
endfunction()


 # script to test the function locally without running vcpkg. Uncomment fix filepaths and use cmake -P vcpkg_fixup_pkgconfig
 # set(_file "G:\\xlinux\\packages\\xlib_x64-windows\\lib\\pkgconfig\\x11.pc")
 # include(${CMAKE_CURRENT_LIST_DIR}/vcpkg_common_definitions.cmake)
 # file(READ "${_file}" _contents)
 # set(CURRENT_INSTALLED_DIR "G:/xlinux/installed/x64-windows")
 # set(CURRENT_PACKAGES_DIR "G:/xlinux/packages/xlib_x64-windows")
 # set(_vfpkg_SYSTEM_LIBRARIES "blu\\ ub")
 # set(_vfpkg_SYSTEM_PACKAGES "szip")
 # vcpkg_fixup_pkgconfig_check_libraries("RELEASE" _contents "${_vfpkg_SYSTEM_LIBRARIES}" "${_vfpkg_SYSTEM_PACKAGES}")
