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
## ### SYSTEM_PACKAGES
## If the *.pc file contains system packages outside vcpkg these need to be listed here.
## Since vcpkg checks the existence of all required packages within vcpkg. 
##
## ### SYSTEM_LIBRARIES
## If the *.pc file contains system libraries outside vcpkg these need to be listed here.
## VCPKG checks every -l flag for the existence of the required library within vcpkg. 
##
## ### IGNORE_FLAGS
## If the *.pc file contains flags in the lib field which are not libraries. These can be listed here
##
## ## Notes
## Still work in progress. If there are more cases which can be handled here feel free to add them
##
## ## Examples
##
## Just call vcpkg_fixup_pkgconfig() after any install step which installs *.pc files. 
function(vcpkg_fixup_pkgconfig_check_libraries _config _contents_var _system_libs _system_packages _ignore_flags)
    set(CMAKE_FIND_LIBRARY_SUFFIXES_BACKUP ${CMAKE_FIND_LIBRARY_SUFFIXES})
    list(APPEND CMAKE_FIND_LIBRARY_SUFFIXES ".lib;.dll.a;.a")
    #message(STATUS "Checking configuration: ${_config}")
    if("${_config}" STREQUAL "DEBUG")
        set(prefix "${CURRENT_INSTALLED_DIR}/debug/")
        set(libprefix "${CURRENT_INSTALLED_DIR}/debug/lib/")
        set(installprefix "${CURRENT_PACKAGES_DIR}/debug/")
        set(installlibprefix "${CURRENT_PACKAGES_DIR}/debug/lib/")
        set(lib_suffixes d _d _debug)
    elseif("${_config}" STREQUAL "RELEASE")
        set(prefix "${CURRENT_INSTALLED_DIR}")
        set(libprefix "${CURRENT_INSTALLED_DIR}/lib/")
        set(installprefix "${CURRENT_PACKAGES_DIR}/")
        set(installlibprefix "${CURRENT_PACKAGES_DIR}/lib/")
        set(lib_suffixes "")
    else()
        message(FATAL_ERROR "Unknown configuration in vcpkg_fixup_pkgconfig_check_libraries!")
    endif()
    debug_message("Default library search paths: ${libprefix} --- ${installlibprefix} --- ${PKG_LIB_SEARCH_PATH}")
    set(_contents "${${_contents_var}}")
    #message(STATUS "Contents: ${_contents}")
    set(_system_lib_normalized)
    foreach(_system_lib ${_system_libs})
        string(REPLACE "-l" "" _system_lib "${_system_lib}")
        list(APPEND _system_lib_normalized "${_system_lib}")
    endforeach()
    
    ## Extra libraries:
    string(REGEX MATCH "Libs:[^\n]+" _libs "${_contents}")
    #message(STATUS "LIB LINE: ${_libs}")
    # The path to the library is either quoted and can not contain a quote or it is unqouted and cannot contain a single unescaped space
    string(REGEX REPLACE "Libs:" "" _libs_list_tmp "${_libs}")
    string(REGEX REPLACE [[[\t ]+(-(l|L)?("[^"]+"|(\\ |[^ ]+)+))]] ";\\1" _libs_list_tmp "${_libs_list_tmp}")

    string(REGEX MATCH "Libs.private:[^\n]+" _libs_private "${_contents}")
    string(REGEX REPLACE "Libs.private:" "" _libs_private_list_tmp "${_libs_private}")
    string(REGEX REPLACE [[[\t ]+(-(l|L)?("[^"]+"|(\\ |[^ ]+)+))]] ";\\1" _libs_private_list_tmp "${_libs_private_list_tmp}")

    #message(STATUS "Found libraries: ${_libs_list_tmp}")
    #message(STATUS "Found private libraries: ${_libs_private_list_tmp}")
    list(APPEND _all_libs "${_libs_list_tmp}" "${_libs_private_list_tmp}")
    list(REMOVE_DUPLICATES _all_libs)
    foreach(_lib ${_all_libs})
        string(REGEX REPLACE "(^[\t ]+|[\t ]+$)" "" _lib "${_lib}") # Remove whitespaces at begin & end
        if( "x${_lib}x" STREQUAL "xx") #Empty String
            continue()
        endif()
        unset(CHECK_LIB CACHE)
        unset(NO_CHECK_LIB)
        #message(STATUS "CHECKING: x${_lib}z")
        if("${_lib}" MATCHES "^-L((\\ |[^ ]+)+)$")
            debug_message("Search path for libraries (unused): ${CMAKE_MATCH_1}") # not used yet we assume everything can be found in libprefix
            continue()
        elseif("${_lib}" MATCHES [[^-l("[^"]+"|(\\ |[^ ]+)+)$]] )
            set(_libname ${CMAKE_MATCH_1})
            debug_message("Searching for library: ${_libname}")
            #debug_message("System libraries: ${_system_libs}")
            foreach(_system_lib ${_system_libs})
                string(REPLACE "^[\t ]*-l" "" _libname_norm "${_libname}")
                string(REGEX REPLACE "[\t ]+$" "" _libname_norm "${_libname_norm}")
                #debug_message("${_libname_norm} vs ${_system_lib}")
                if("${_libname_norm}" MATCHES "${_system_lib}" OR "-l${_libname_norm}" MATCHES "${_system_lib}")
                    set(NO_CHECK_LIB ON)
                    debug_message("${_libname} is SYSTEM_LIBRARY")
                    break()
                endif()
            endforeach()
            if(NO_CHECK_LIB)
                break()
            endif()
            #debug_message("Searching for library ${_libname} in ${libprefix}")
            if(EXISTS "${_libname}") #full path
                set(CHECK_LIB_${_libname} "${_libname}" CACHE INTERNAL FORCE)
            endif()
            find_library(CHECK_LIB_${_libname} NAMES "${_libname}" PATHS "${libprefix}" "${installlibprefix}" "${PKG_LIB_SEARCH_PATH}" NO_DEFAULT_PATH)
            if(NOT CHECK_LIB_${_libname} AND "${_config}" STREQUAL "DEBUG")
                #message(STATUS "Unable to locate ${_libname}. Trying with debug suffix")
                foreach(_lib_suffix ${lib_suffixes})
                    string(REPLACE ".dll.a|.a|.lib|.so" "" _name_without_extension "${_libname}")
                    find_library(CHECK_LIB_${_libname} NAMES ${_name_without_extension}${_lib_suffix} PATHS "${libprefix}" "${installlibprefix}" "${PKG_LIB_SEARCH_PATH}")
                    if(CHECK_LIB_${_libname})
                        message(FATAL_ERROR "Found ${CHECK_LIB_${_libname}} with additional debug suffix! Please correct the *.pc file!")
                        string(REGEX REPLACE "(-l${_name_without_extension})(\.dll\.a|\.a|\.lib|\.so)" "\\1${_lib_suffix}\\2" _contents ${_contents})
                    endif()
                endforeach()
                if(NOT CHECK_LIB_${_libname})
                    message(FATAL_ERROR "Library ${_libname} was not found! If it is a system library use the SYSTEM_LIBRARIES parameter for the vcpkg_fixup_pkgconfig call! Otherwise, corret the *.pc file")
                endif()
            elseif(NOT CHECK_LIB_${_libname})
                message(FATAL_ERROR "Library ${_libname} was not found! If it is a system library use the SYSTEM_LIBRARIES parameter for the vcpkg_fixup_pkgconfig call! Otherwise, corret the *.pc file")
            else()
                debug_message("Found ${_libname} at ${CHECK_LIB_${_libname}}")
            endif()
        else()
            #handle special cases
            if(_lib STREQUAL "-pthread" OR _lib STREQUAL "-pthreads") 
                # Replace with VCPKG version?
                #VCPKG should probably rename one of the pthread versions to avoid linking against system pthread? 
                # set(PTHREAD_SUFFIX )
                # if("${_config}" STREQUAL "DEBUG")
                    # file(GLOB PTHREAD_LIB "${CURRENT_INSTALLED_DIR}/debug/lib/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}pthread*C3d.*")
                # elseif("${_config}" STREQUAL "RELEASE")
                    # file(GLOB PTHREAD_LIB "${CURRENT_INSTALLED_DIR}/lib/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}pthread*C3.*")
                # endif()
                # get_filename_component(PTHREAD_LIB "${PTHREAD_LIB}" NAME_WE)
                # string(REPLACE "Libs: -pthread" "Libs: -L\${libdir} -l${PTHREAD_LIB}" _contents ${_contents})
            else()
                message(FATAL_ERROR "Found ${_lib} and no rule to analyse the flag! Please check the *.pc file")
            endif()
        endif()
        unset(CHECK_LIB_${_libname} CACHE)
        unset(NO_CHECK_LIB)
    endforeach()

    ## Packages:
    string(REGEX MATCH "Requires:[^\n]+" _pkg_list_tmp "${_contents}")
    string(REGEX REPLACE "Requires:[\t ]" "" _pkg_list_tmp "${_pkg_list_tmp}")
    string(REGEX REPLACE "[\t ]*,[\t ]*" ";" _pkg_list_tmp "${_pkg_list_tmp}")
    string(REGEX REPLACE "[\t ]*(>|=)+[\t ]*([0-9]+|\\.)+" "" _pkg_list_tmp "${_pkg_list_tmp}")
    string(REGEX REPLACE " " ";" _pkg_list_tmp "${_pkg_list_tmp}")
    string(REGEX MATCH "Requires.private:[^\n]+" _pkg_private_list_tmp "${_contents}")
    string(REGEX REPLACE "Requires.private:[\t ]" "" _pkg_private_list_tmp "${_pkg_private_list_tmp}")
    string(REGEX REPLACE "[\t ]*,[\t ]*" ";" _pkg_private_list_tmp "${_pkg_private_list_tmp}")
    string(REGEX REPLACE "[\t ]*(>|=)+[\t ]*([0-9]+|\\.)+" " " _pkg_private_list_tmp "${_pkg_private_list_tmp}")
    string(REGEX REPLACE "[\t ]+" ";" _pkg_private_list_tmp "${_pkg_private_list_tmp}")
    
    debug_message("Required packages: ${_pkg_list_tmp}")
    debug_message("Required private packages: ${_pkg_private_list_tmp}")
    
    #message(STATUS "System packages: ${_system_packages}")
    foreach(_package  ${_pkg_list_tmp} ${_pkg_private_list_tmp})
        debug_message("Searching for package: ${_package}")
        set(PKG_CHECK ON)
        if(NOT "${_system_packages}" STREQUAL "")
            #message(STATUS "Checking ${_package} for SYSTEM PACKAGE: ${_system_packages}") 
            if("${_system_packages}" MATCHES "${_package}" )
                debug_message("Package ${_package} is SYSTEM PACKAGE!") 
                set(PKG_CHECK OFF)
            endif()
        endif()
        if(PKG_CHECK AND NOT (EXISTS "${libprefix}/pkgconfig/${_package}.pc" OR EXISTS "${installlibprefix}/pkgconfig/${_package}.pc" OR EXISTS "${PKG_LIB_SEARCH_PATH}/pkgconfig/${_package}.pc"))
            message(FATAL_ERROR "Package ${_package} not found! If it is a system package add it to the SYSTEM_PACKAGES parameter for the vcpkg_fixup_pkgconfig call! Otherwise, corret the *.pc file")
        else()
            debug_message("Found package ${_package}!")
        endif()
    endforeach()
    ## Push modifications up in scope
    set(${_contents_var} "${_contents}" PARENT_SCOPE)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_BACKUP})
endfunction()

function(vcpkg_fixup_pkgconfig)
    cmake_parse_arguments(_vfpkg "" "" "RELEASE_FILES;DEBUG_FILES;SYSTEM_LIBRARIES;SYSTEM_PACKAGES;IGNORE_FLAGS" ${ARGN})
    
    if(VCPKG_TARGET_IS_LINUX)
        list(APPEND _vfpkg_SYSTEM_LIBRARIES -ldl -lm)
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
    
    #Absolute Unix like paths 
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}")
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}")
    
    message(STATUS "Fixing pkgconfig - release")
    debug_message("Files: ${_vfpkg_RELEASE_FILES}")
    foreach(_file ${_vfpkg_RELEASE_FILES})
        message(STATUS "Checking file: ${_file}")
        get_filename_component(PKG_LIB_SEARCH_PATH "${_file}" DIRECTORY)
        string(REGEX REPLACE "/pkgconfig/?" "" PKG_LIB_SEARCH_PATH "${PKG_LIB_SEARCH_PATH}")
        file(READ "${_file}" _contents)
        string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${_VCPKG_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${_VCPKG_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        string(REGEX REPLACE "^prefix=\\\${prefix}" "#prefix=${CURRENT_INSTALLED_DIR}" _contents "${_contents}") # Comment out prefix
        vcpkg_fixup_pkgconfig_check_libraries("RELEASE" _contents "${_vfpkg_SYSTEM_LIBRARIES}" "${_vfpkg_SYSTEM_PACKAGES}" "${_vfpkg_IGNORE_FLAGS}")
        file(WRITE "${_file}" "${_contents}")
        unset(PKG_LIB_SEARCH_PATH)
    endforeach()
    
    message(STATUS "Fixing pkgconfig - debug")
    debug_message("Files: ${_vfpkg_DEBUG_FILES}")
    foreach(_file ${_vfpkg_DEBUG_FILES})
        message(STATUS "Checking file: ${_file}")
        get_filename_component(PKG_LIB_SEARCH_PATH "${_file}" DIRECTORY)
        string(REGEX REPLACE "/pkgconfig/?" "" PKG_LIB_SEARCH_PATH "${PKG_LIB_SEARCH_PATH}")
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
        string(REGEX REPLACE "^prefix=\\\${prefix}/debug" "#prefix=${CURRENT_INSTALLED_DIR}/debug" _contents "${_contents}") # Comment out prefix
        string(REPLACE "\${prefix}/debug" "\${prefix}" _contents "${_contents}") # replace remaining debug paths if they exist. 
        vcpkg_fixup_pkgconfig_check_libraries("DEBUG" _contents "${_vfpkg_SYSTEM_LIBRARIES}" "${_vfpkg_SYSTEM_PACKAGES}" "${_vfpkg_IGNORE_FLAGS}")
        file(WRITE "${_file}" "${_contents}")
        unset(PKG_LIB_SEARCH_PATH)
    endforeach()
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
