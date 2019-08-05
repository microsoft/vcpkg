vcpkg_define_function_overwrite_option(find_package)
CMAKE_DEPENDENT_OPTION(VCPKG_ENABLE_FIND_PACKAGE_EXTERNAL_OVERRIDE "Tells VCPKG to use _find_package instead of find_package." OFF "NOT VCPKG_ENABLE_FIND_PACKAGE" OFF)
mark_as_advanced(VCPKG_ENABLE_FIND_PACKAGE_EXTERNAL_OVERRIDE)

macro(vcpkg_find_package name)
    string(TOLOWER "${name}" _vcpkg_lowercase_name)
    string(TOUPPER "${name}" _vcpkg_uppercase_name)
    if(EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/${_vcpkg_lowercase_name}/vcpkg-cmake-wrapper.cmake")
        vcpkg_msg(STATUS "find_package" "Using vcpkg-cmake-wrapper.cmake for package: ${name}!")
        set(ARGS "${ARGV}")
        include(${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/${_vcpkg_lowercase_name}/vcpkg-cmake-wrapper.cmake)
    elseif("${name}" STREQUAL "Boost" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/boost")
        #TODO: put into vcpkg_cmake_wrapper.cmake
        # Checking for the boost headers disables this wrapper unless the user has installed at least one boost library
        set(Boost_USE_STATIC_LIBS OFF)
        set(Boost_USE_MULTITHREADED ON)
        unset(Boost_USE_STATIC_RUNTIME)
        set(Boost_NO_BOOST_CMAKE ON)
        unset(Boost_USE_STATIC_RUNTIME CACHE)
        set(Boost_COMPILER "-vc140")
        _find_package(${ARGV})
    elseif("${name}" STREQUAL "ICU" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/unicode/utf.h")
        #TODO: put into vcpkg_cmake_wrapper.cmake
        function(_vcpkg_find_in_list)
            list(FIND ARGV "COMPONENTS" COMPONENTS_IDX)
            set(COMPONENTS_IDX ${COMPONENTS_IDX} PARENT_SCOPE)
        endfunction()
        _vcpkg_find_in_list(${ARGV})
        if(NOT COMPONENTS_IDX EQUAL -1)
            _find_package(${ARGV} COMPONENTS data)
        else()
            _find_package(${ARGV})
        endif()
    elseif("${_vcpkg_lowercase_name}" STREQUAL "grpc" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/grpc")
        #TODO: put into vcpkg_cmake_wrapper.cmake
        _find_package(gRPC ${ARGN})
    else()
        # If package does not define targets and only uses old school variables we have to fix the paths to the libraries since
        # find_package will only find the debug libraries or only find the release libraries if the name of the library was 
        # changed for debug builds. 
        _find_package(${ARGV})

        # cmake_policy(PUSH)
        # cmake_policy(SET CMP0054 NEW)

        # get_cmake_property(_pkg_all_vars VARIABLES)

        #general find_package debug info. show all defined package variables to examine if they are set wrong
        set(_pkg_names_rgx "(${name}|${_vcpkg_uppercase_name}|${_vcpkg_lowercase_name})")
        #need to escape special regex characters
        string(REPLACE "+" "\\+" _pkg_names_rgx "${_pkg_names_rgx}")
        string(REPLACE "*" "\\*" _pkg_names_rgx "${_pkg_names_rgx}")
        set(_pkg_filter_rgx "^(${_pkg_names_rgx})([^_]*_)+")
        list(FILTER _pkg_all_vars INCLUDE REGEX ${_pkg_filter_rgx})
        vcpkg_msg(status "find_package" " all vars defined after find_package call: ${_pkg_all_vars}") # good for debugging the regex
        foreach(_pkg_var ${_pkg_all_vars})
            vcpkg_msg(status "find_package" "value of ${_pkg_var}: ${${_pkg_var}}")
        endforeach()
        
        # #Fixing Libraries paths.
        # #Filtering for variables which are probably library variables for the package.
        set(_pkg_filter_rgx "^(${_pkg_names_rgx})([^_]*_)+(LIBRAR|LIBS)")
        list(FILTER _pkg_all_vars INCLUDE REGEX ${_pkg_filter_rgx})
        # vcpkg_msg(STATUS "find_package" "Filtered-libraries-vars: ${_pkg_all_vars}")

        # list(FILTER _pkg_all_vars EXCLUDE REGEX "(_RELEASE|_DEBUG)")# Excluding debug and releas libraries from fixing (they should be handled by find_library.)
        
        # if(DEFINED VCPKG_BUILD_TYPE OR "${_pkg_all_vars}" MATCHES "_CONFIG")
            # vcpkg_msg(STATUS "find_package" "VCPKG_BUILD_TYPE or CONFIG found. Skipping loop.")
        # else()
            # #Since everthing is fixed by find_library the fix here shouldn't be required
            # foreach(_pkg_var ${_pkg_all_vars})
                # vcpkg_msg(STATUS "find_package" "Filtered: Value of ${_pkg_var}: ${${_pkg_var}}")
                # # if(not "${${_pkg_var}}"      matches "(optimized;|[cc][oo][nn][ff][ii][gg]:[rr][ee][ll][ee][aa][ss][ee])" 
                   # # and not "${${_pkg_var}}"  matches "(debug;|[cc][oo][nn][ff][ii][gg]:[dd][ee][bb][uu][gg])" 
                   # # and ("${${_pkg_var}}"     matches "${_vcpkg_installed_dir}/${vcpkg_target_triplet}/lib" 
                         # # or "${${_pkg_var}}" matches "${_vcpkg_installed_dir}/${vcpkg_target_triplet}/debug/lib"))
                    # # # optimized,debug or generator expression not found within the package variable. need to probably fix the variable to generate correct targets!
                    # # # the only thing this thing should still fix is "<packagename>_librar(y|ies)_dirs?" all other variables should be fixed by find_library!
                    # # # most of the times the "dirs?" variable is set by a find_path call to an include file and then the relativ path "../lib" is added. 
                    # # set(_pkg_var_new "${${_pkg_var}}")
                    # # if("${${_pkg_var}}" matches "${_vcpkg_installed_dir}/${vcpkg_target_triplet}/debug") # no need to guard from generator expression; already done above. 
                        # # # debug path found
                        # # if(cmake_build_type matches "^[rr][ee][ll][ee][aa][ss][ee]$") 
                            # # vcpkg_msg(warning "find_package-fix" "found debug path in release build in variable ${_pkg_var}! path: ${${_pkg_var}}")
                        # # endif()
                   # # else()
                        # # # release path found
                        # # if(cmake_build_type matches "^[dd][ee][bb][uu][gg]$")
                            # # vcpkg_msg(warning "find_package-fix" "found release path in debug build in variable ${_pkg_var}! path: ${${_pkg_var}}")
                        # # endif()
                   # # endif()
                # # endif()
            # endforeach()
        #endif()
        #cmake_policy(POP)
    endif()
endmacro()

if(VCPKG_ENABLE_find_package)
    # Must be a macro since we do not know which variables are being set and thus cannot propagte them into PARENT_SCOPE from a function. 
    macro(find_package name)
        # Cannot use the loop protection in find_package because a module might want to also call find_package but with other parameters. 
        # Using only the parameter count is thus not enough to make sure that the guard is correct. Needs additional some kind of hash dependent on the parameterlist to be correct. 
        #if(DEFINED _vcpkg_find_package_guard_${name}${ARGC})
        #    vcpkg_msg(FATAL_ERROR "find_package" "INFINIT LOOP DETECTED. Guard _vcpkg_find_package_guard_${name}${ARGC}. Did you supply your own find_package override? \n \
        #                            If yes: please set VCPKG_ENABLE_FIND_PACKAGE off and call vcpkg_find_package if you want to have vcpkg corrected behavior. \n \
        #                            If no: please open an issue on GITHUB describe the fail case!" ALWAYS)
        #else()
        #    set(_vcpkg_find_package_guard_${name}${ARGC} ON)
        #endif()
        vcpkg_find_package(${ARGV})
        #unset(_vcpkg_find_package_guard_${name}${ARGC})
    endmacro()
endif()