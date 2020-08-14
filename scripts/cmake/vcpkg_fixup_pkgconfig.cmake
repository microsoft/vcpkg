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
function(vcpkg_fixup_pkgconfig_check_files pkg_cfg_cmd _file _config _system_libs _ignore_flags)
    # Setup pkg-config paths
    if(CMAKE_HOST_WIN32)
        # Those replacements are probably only necessary since we use pkg-config from msys
        string(REPLACE " " "\ " _VCPKG_INSTALLED_PKGCONF "${CURRENT_INSTALLED_DIR}")
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_PKGCONF "${_VCPKG_INSTALLED_PKGCONF}")
        string(REPLACE "\\" "/" _VCPKG_INSTALLED_PKGCONF "${_VCPKG_INSTALLED_PKGCONF}")
        string(REPLACE " " "\ " _VCPKG_PACKAGES_PKGCONF "${CURRENT_PACKAGES_DIR}")
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PACKAGES_PKGCONF "${_VCPKG_PACKAGES_PKGCONF}")
        string(REPLACE "\\" "/" _VCPKG_PACKAGES_PKGCONF "${_VCPKG_PACKAGES_PKGCONF}")
    else()
        set(_VCPKG_INSTALLED_PKGCONF "${CURRENT_INSTALLED_DIR}")
        set(_VCPKG_PACKAGES_PKGCONF "${CURRENT_PACKAGES_DIR}")
    endif()
    
    set(PATH_SUFFIX_DEBUG /debug)
    set(PKGCONFIG_INSTALLED_DIR "${_VCPKG_INSTALLED_PKGCONF}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
    set(PKGCONFIG_INSTALLED_SHARE_DIR "${_VCPKG_INSTALLED_PKGCONF}/share/pkgconfig")
    set(PKGCONFIG_PACKAGES_DIR "${_VCPKG_PACKAGES_PKGCONF}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
    set(PKGCONFIG_PACKAGES_SHARE_DIR "${_VCPKG_PACKAGES_PKGCONF}/share/pkgconfig")

    if(ENV{PKG_CONFIG_PATH})
        set(BACKUP_ENV_PKG_CONFIG_PATH_${_config} $ENV{PKG_CONFIG_PATH})
        set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}:${PKGCONFIG_INSTALLED_SHARE_DIR}:${PKGCONFIG_PACKAGES_DIR}:${PKGCONFIG_PACKAGES_SHARE_DIR}:$ENV{PKG_CONFIG_PATH}")
    else()
        set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}:${PKGCONFIG_INSTALLED_SHARE_DIR}:${PKGCONFIG_PACKAGES_DIR}:${PKGCONFIG_PACKAGES_SHARE_DIR}")
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

    execute_process(COMMAND "${pkg_cfg_cmd}" --print-errors --static --libs-only-L ${_package_name}
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                    RESULT_VARIABLE _pkg_error_var
                    OUTPUT_VARIABLE _pkg_lib_paths_output
                    ERROR_VARIABLE  _pkg_error_out
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE
                    )

    if(NOT _pkg_error_var EQUAL 0)
        message(STATUS "pkg_cfg_cmd call with:${pkg_cfg_cmd} --libs-only-L ${_package_name} failed")
        message(STATUS "pkg-config call failed with error code:${_pkg_error_var}")
        message(STATUS "pkg-config output:${_pkg_lib_paths_output}")
        message(FATAL_ERROR "pkg-config error output:${_pkg_error_out}")
    else()
        debug_message("pkg-config returned:${_pkg_error_var}")
        debug_message("pkg-config output:${_pkg_lib_paths_output}")
        debug_message("pkg-config error output:${_pkg_error_out}")
    endif()

    string(REPLACE "\\ " "##" _pkg_lib_paths_output "${_pkg_lib_paths_output}") # Whitespace path protection
    string(REGEX REPLACE "(^[\t ]*|[\t ]+)-L" ";" _pkg_lib_paths_output "${_pkg_lib_paths_output}")
    debug_message("-L LIST TRANSFORMATION:'${_pkg_lib_paths_output}'")
    string(REGEX REPLACE "^[\t ]*;" "" _pkg_lib_paths_output "${_pkg_lib_paths_output}")
    string(REPLACE "##" "\\ " _pkg_lib_paths_output "${_pkg_lib_paths_output}")

    list(REMOVE_DUPLICATES _pkg_lib_paths_output) # We don't care about linker order and repeats
    ## Remove search paths from LIBS
    foreach(_search_path IN LISTS _pkg_lib_paths_output)
        debug_message("REMOVING:'${_search_path}'")
        debug_message("FROM:'${_pkg_libs_output}'")
        string(REGEX REPLACE "(^[\t ]*|[\t ]+|;[\t ]*)-L${_search_path}([\t ]+|[\t ]*$)" ";" _pkg_libs_output "${_pkg_libs_output}") # Remove search paths from libs
    endforeach()
    debug_message("LIBS AFTER -L<path> REMOVAL:'${_pkg_libs_output}'")

    #Make the remaining libs a proper CMake List
    string(REPLACE "\\ " "##" _pkg_libs_output "${_pkg_libs_output}") # Whitespace path protection
    string(REGEX REPLACE "(^[\t ]*|[\t ]+)-l" ";-l" _pkg_libs_output "${_pkg_libs_output}")
    string(REGEX REPLACE "[\t ]*(-pthreads?)" ";\\1" _pkg_libs_output "${_pkg_libs_output}") # handle pthread without -l here (makes a lot of problems otherwise)
    string(REGEX REPLACE "^[\t ]*;[\t ]*" "" _pkg_libs_output "${_pkg_libs_output}")
    string(REPLACE "##" "\\ " _pkg_libs_output "${_pkg_libs_output}")

    #Windows path transformations
    if(CMAKE_HOST_WIN32)
        string(REGEX REPLACE "(^|;)/([a-zA-Z])/" "\\1\\2:/" _pkg_lib_paths_output "${_pkg_lib_paths_output}")
        string(REGEX REPLACE " /([a-zA-Z])/" ";\\1:/" _pkg_libs_output "${_pkg_libs_output}")
        string(REGEX REPLACE "-l/([a-zA-Z])/" "-l\\1:/" _pkg_libs_output "${_pkg_libs_output}")
        debug_message("pkg-config output lib paths after replacement (cmake style):${_pkg_lib_paths_output}")
        debug_message("pkg-config output lib after replacement (cmake style):${_pkg_libs_output}")
    endif()

    if("${_config}" STREQUAL "DEBUG")
        set(lib_suffixes d _d _debug -s -sd _s _sd -static -staticd _static _staticd)
    elseif("${_config}" STREQUAL "RELEASE")
        set(lib_suffixes -s _s -static _static)
    else()
        message(FATAL_ERROR "Unknown configuration in vcpkg_fixup_pkgconfig_check_libraries!")
    endif()

    debug_message("IGNORED FLAGS:'${_ignore_flags}'")
    debug_message("BEFORE IGNORE FLAGS REMOVAL: ${_pkg_libs_output}")
    foreach(_ignore IN LISTS _ignore_flags)  # Remove ignore with whitespace
        debug_message("REMOVING FLAG:'${_ignore}'")
        string(REGEX REPLACE "(^[\t ]*|;[\t ]*|[\t ]+)${_ignore}([\t ]+|[\t ]*;|[\t ]*$)" "\\2" _pkg_libs_output "${_pkg_libs_output}")
        debug_message("AFTER REMOVAL: ${_pkg_libs_output}")
    endforeach()

    string(REGEX REPLACE ";?[\t ]*;[\t ]*" ";" _pkg_libs_output "${_pkg_libs_output}") # Double ;; and Whitespace before/after ; removal

    debug_message("SYSTEM LIBRARIES:'${_system_libs}'")
    debug_message("LIBRARIES in PC:'${_pkg_libs_output}'")
    foreach(_system_lib IN LISTS _system_libs)  # Remove system libs with whitespace
        debug_message("REMOVING:'${_system_lib}'")
        debug_message("FROM:'${_pkg_libs_output}'")
        string(REGEX REPLACE "(^[\t ]*|;[\t ]*|[\t ]+)(-l?)${_system_lib}([\t ]+|[\t ]*;|[\t ]*$)" "\\3" _pkg_libs_output "${_pkg_libs_output}")
        string(REGEX REPLACE "(^[\t ]*|;[\t ]*|[\t ]+)${_system_lib}([\t ]+|[\t ]*;|[\t ]*$)" "\\2" _pkg_libs_output "${_pkg_libs_output}")
        string(TOLOWER "${_system_lib}" _system_lib_lower)
        string(REGEX REPLACE "(^[\t ]*|;[\t ]*|[\t ]+)(-l?)${_system_lib_lower}([\t ]+|[\t ]*;|[\t ]*$)" "\\3" _pkg_libs_output "${_pkg_libs_output}")
        string(REGEX REPLACE "(^[\t ]*|;[\t ]*|[\t ]+)${_system_lib_lower}([\t ]+|[\t ]*;|[\t ]*$)" "\\2" _pkg_libs_output "${_pkg_libs_output}")
        debug_message("AFTER REMOVAL:'${_pkg_libs_output}'")
    endforeach()
    list(REMOVE_DUPLICATES _pkg_libs_output) # We don't care about linker order and repeats

    string(REGEX REPLACE ";?[\t ]*;[\t ]*" ";" _pkg_libs_output "${_pkg_libs_output}") # Double ;; and Whitespace before/after ; removal

    debug_message("Library search paths:${_pkg_lib_paths_output}")
    debug_message("Libraries to search:${_pkg_libs_output}")
    set(CMAKE_FIND_LIBRARY_SUFFIXES_BACKUP ${CMAKE_FIND_LIBRARY_SUFFIXES})
    list(APPEND CMAKE_FIND_LIBRARY_SUFFIXES .lib .dll.a .a)
    foreach(_lib IN LISTS _pkg_libs_output)
        if(EXISTS "${_lib}" OR "x${_lib}x" STREQUAL "xx" ) # eat; all ok _lib is a fullpath to a library or empty
            continue()
        elseif (_lib MATCHES "^-l(.+)$")
            debug_message("Library match: CMAKE_MATCH_1:${CMAKE_MATCH_1}")
            set(_libname "${CMAKE_MATCH_1}")
            if(EXISTS "${_libname}")
                debug_message("${_libname} detected as an existing full path!")
                continue() # fullpath in -l argument and exists; all ok
            endif()
            debug_message("CHECK_LIB_${_libname}_${_config} before: ${CHECK_LIB_${_libname}_${_config}}")
            find_library(CHECK_LIB_${_libname}_${_config} NAMES ${_libname} PATHS ${_pkg_lib_paths_output} "${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_config}}/lib" NO_DEFAULT_PATH)
            debug_message("CHECK_LIB_${_libname}_${_config} after: ${CHECK_LIB_${_libname}_${_config}}")
            if(CHECK_LIB_${_libname}_${_config})
                unset(CHECK_LIB_${_libname}_${_config} CACHE) # need to unset or else other configurations will not check correctly
                debug_message("CHECK_LIB_${_libname}_${_config} after unset: ${CHECK_LIB_${_libname}_${_config}}")
                continue() # found library; all ok
            endif()
            debug_message("Searching with additional suffixes: '${lib_suffixes}'")
            foreach(_lib_suffix IN LISTS lib_suffixes)
                string(REPLACE ".dll.a|.a|.lib|.so" "" _name_without_extension "${_libname}")
                set(search_name ${_name_without_extension}${_lib_suffix})
                debug_message("Search name: '${search_name}'")
                debug_message("CHECK_LIB_${search_name}_${_config} before: ${CHECK_LIB_${search_name}_${_config}}")
                debug_message("Search paths:'${_pkg_lib_paths_output}' '${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_config}}/lib'")
                find_library(CHECK_LIB_${search_name}_${_config} NAMES ${search_name} PATHS ${_pkg_lib_paths_output} "${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_config}}/lib" NO_DEFAULT_PATH)
                debug_message("CHECK_LIB_${search_name}_${_config} after: ${CHECK_LIB_${search_name}_${_config}}")
                if(CHECK_LIB_${search_name}_${_config})
                    message(FATAL_ERROR "Found ${CHECK_LIB_${search_name}_${_config}} with additional '${_lib_suffix}' suffix! Please correct the *.pc file!")
                    unset(CHECK_LIB_${search_name}_${_config} CACHE) # need to unset or else other configurations will not check correctly
                endif()
            endforeach()
            # Reaching here means error!
            message(STATUS "CHECK_LIB_${_libname}_${_config}:${CHECK_LIB_${_libname}_${_config}}")
            message(FATAL_ERROR "Library \"${_libname}\" was not found! If it is a system library use the SYSTEM_LIBRARIES parameter for the vcpkg_fixup_pkgconfig call! Otherwise, correct the *.pc file")
        else ()
            message(FATAL_ERROR "Unhandled string \"${_lib}\" was found! If it is a system library use the SYSTEM_LIBRARIES parameter for the vcpkg_fixup_pkgconfig call! Otherwise, correct the *.pc file or add the case to vcpkg_fixup_pkgconfig")
        endif()
    endforeach()

    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_BACKUP})
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
    
    message(STATUS "Fixing pkgconfig")
    if(_vfpkg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_pkgconfig was passed extra arguments: ${_vfct_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT _vfpkg_RELEASE_FILES)
        file(GLOB_RECURSE _vfpkg_RELEASE_FILES "${CURRENT_PACKAGES_DIR}/**/*.pc")
        list(FILTER _vfpkg_RELEASE_FILES EXCLUDE REGEX "${CURRENT_PACKAGES_DIR}/debug/")
    endif()

    if(NOT _vfpkg_DEBUG_FILES)
        file(GLOB_RECURSE _vfpkg_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/**/*.pc")
        list(FILTER _vfpkg_DEBUG_FILES INCLUDE REGEX "${CURRENT_PACKAGES_DIR}/debug/")
    endif()

    if(NOT PKGCONFIG)
        find_program(PKGCONFIG pkg-config PATHS "bin" "/usr/bin" "/usr/local/bin")
        if(NOT PKGCONFIG AND CMAKE_HOST_WIN32)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
            find_program(PKGCONFIG pkg-config PATHS "${MSYS_ROOT}/usr/bin" REQUIRED)
        endif()
        debug_message("Using pkg-config from: ${PKGCONFIG}")
        if(NOT PKGCONFIG AND NOT _vfpkg_SKIP_CHECK)
            message(WARNING "Unable to find pkg-config to validate *.pc files. Skipping checkes!")
            set(_vfpkg_SKIP_CHECK TRUE)
        endif()
    endif()

    #Absolute Unix like paths 
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}")
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}")

    message(STATUS "Fixing pkgconfig - release")
    debug_message("Files: ${_vfpkg_RELEASE_FILES}")
    foreach(_file ${_vfpkg_RELEASE_FILES})
        message(STATUS "Checking file: ${_file}")
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
        file(WRITE "${_file}" "${_contents}")
        unset(PKG_LIB_SEARCH_PATH)
    endforeach()

    if(NOT _vfpkg_SKIP_CHECK) # The check can only run after all files have been corrected!
        foreach(_file ${_vfpkg_RELEASE_FILES})
            vcpkg_fixup_pkgconfig_check_files("${PKGCONFIG}" "${_file}" "RELEASE" "${_vfpkg_SYSTEM_LIBRARIES}" "${_vfpkg_IGNORE_FLAGS}")
        endforeach()
    endif()

    message(STATUS "Fixing pkgconfig - debug")
    debug_message("Files: ${_vfpkg_DEBUG_FILES}")
    foreach(_file ${_vfpkg_DEBUG_FILES})
        message(STATUS "Checking file: ${_file}")
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
        file(WRITE "${_file}" "${_contents}")
        unset(PKG_LIB_SEARCH_PATH)
    endforeach()

    if(NOT _vfpkg_SKIP_CHECK) # The check can only run after all files have been corrected!
        foreach(_file ${_vfpkg_DEBUG_FILES})
            vcpkg_fixup_pkgconfig_check_files("${PKGCONFIG}" "${_file}" "DEBUG" "${_vfpkg_SYSTEM_LIBRARIES}" "${_vfpkg_IGNORE_FLAGS}")
        endforeach()
    endif()
    message(STATUS "Fixing pkgconfig --- finished")

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
