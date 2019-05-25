option(VCPKG_ENABLE_FIND_PACKAGE "Enables override of the cmake function find_package." ON)
mark_as_advanced(VCPKG_ENABLE_FIND_PACKAGE)
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
        if(VCPKG_ENABLE_FIND_PACKAGE OR VCPKG_ENABLE_FIND_PACKAGE_EXTERNAL_OVERRIDE)
            _find_package(${ARGV})
        else()
            find_package(${ARGV})
        endif()
    elseif("${name}" STREQUAL "ICU" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/unicode/utf.h")
        #TODO: put into vcpkg_cmake_wrapper.cmake
        function(_vcpkg_find_in_list)
            list(FIND ARGV "COMPONENTS" COMPONENTS_IDX)
            set(COMPONENTS_IDX ${COMPONENTS_IDX} PARENT_SCOPE)
        endfunction()
        _vcpkg_find_in_list(${ARGV})
        if(NOT COMPONENTS_IDX EQUAL -1)
             if(VCPKG_ENABLE_FIND_PACKAGE OR VCPKG_ENABLE_FIND_PACKAGE_EXTERNAL_OVERRIDE)
                _find_package(${ARGV} COMPONENTS data)
            else()
                find_package(${ARGV} COMPONENTS data)
            endif()
        else()
            if(VCPKG_ENABLE_FIND_PACKAGE OR VCPKG_ENABLE_FIND_PACKAGE_EXTERNAL_OVERRIDE)
                _find_package(${ARGV})
            else()
                find_package(${ARGV})
            endif()
        endif()
    elseif("${_vcpkg_lowercase_name}" STREQUAL "grpc" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/grpc")
        #TODO: put into vcpkg_cmake_wrapper.cmake
        if(VCPKG_ENABLE_FIND_PACKAGE OR VCPKG_ENABLE_FIND_PACKAGE_EXTERNAL_OVERRIDE)
            _find_package(gRPC ${ARGN})
        else()
            find_package(gRPC ${ARGN})
        endif()
    else()
        # If package does not define targets and only uses old school variables we have to fix the paths to the libraries since
        # find_package will only find the debug libraries or only find the release libraries if the name of the library was 
        # changed for debug builds. 
        if(VCPKG_ENABLE_FIND_PACKAGE OR VCPKG_ENABLE_FIND_PACKAGE_EXTERNAL_OVERRIDE)
            _find_package(${ARGV})
        else()
            find_package(${ARGV})
        endif()

        cmake_policy(PUSH)
        cmake_policy(SET CMP0054 NEW)

        get_cmake_property(_pkg_all_vars VARIABLES)

        #General find_package debug info. Show all defined package variables to examine if they are set wrong
        set(_pkg_names_rgx "(${name}|${_vcpkg_uppercase_name}|${_vcpkg_lowercase_name})")
        #Need to escape special regex characters
        STRING(REPLACE "+" "\\+" _pkg_names_rgx "${_pkg_names_rgx}")
        STRING(REPLACE "*" "\\*" _pkg_names_rgx "${_pkg_names_rgx}")
        set(_pkg_filter_rgx "^(${_pkg_names_rgx})([^_]*_)+")
        list(FILTER _pkg_all_vars INCLUDE REGEX ${_pkg_filter_rgx})
        vcpkg_msg(STATUS "find_package" " All vars defined after find_package call: ${_pkg_all_vars}") # Good for debugging the regex
        foreach(_pkg_var ${_pkg_all_vars})
            vcpkg_msg(STATUS "find_package" "Value of ${_pkg_var}: ${${_pkg_var}}")
        endforeach()
        
        #Fixing Libraries paths.
        #Filtering for variables which are probably library variables for the package.
        set(_pkg_filter_rgx "^(${_pkg_names_rgx})([^_]*_)+(LIBRAR|LIBS)")
        list(FILTER _pkg_all_vars INCLUDE REGEX ${_pkg_filter_rgx})
        vcpkg_msg(STATUS "find_package" "Filtered-libraries-vars: ${_pkg_all_vars}")

        list(FILTER _pkg_all_vars EXCLUDE REGEX "(_RELEASE|_DEBUG)")# Excluding debug and releas libraries from fixing (they should be handled by find_library.)
        
        if(DEFINED VCPKG_BUILD_TYPE OR "${_pkg_all_vars}" MATCHES "_CONFIG")
            vcpkg_msg(STATUS "find_package" "VCPKG_BUILD_TYPE or CONFIG found. Skipping loop to fix package variables.")
        else()
            #Since everthing is fixed by find_library the fix here shouldn't be required
            foreach(_pkg_var ${_pkg_all_vars})
                vcpkg_msg(STATUS "find_package" "Filtered: Value of ${_pkg_var}: ${${_pkg_var}}")
                if(NOT "${${_pkg_var}}"      MATCHES "(optimized;|[Cc][Oo][Nn][Ff][Ii][Gg]:[Rr][Ee][Ll][Ee][Aa][Ss][Ee])" 
                   AND NOT "${${_pkg_var}}"  MATCHES "(debug;|[Cc][Oo][Nn][Ff][Ii][Gg]:[Dd][Ee][Bb][Uu][Gg])" 
                   AND ("${${_pkg_var}}"     MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" 
                         OR "${${_pkg_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib"))
                    # optimized,debug or generator expression not found within the package variable. Need to probably fix the variable to generate correct targets!
                    set(_pkg_var_new "${${_pkg_var}}")
                    if("x${${_pkg_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug") # No need to guard from generator expression; already done above. 
                        # Debug Path found
                        if(CMAKE_BUILD_TYPE MATCHES "^Release$") 
                            vcpkg_msg(WARNING "find_package-fix" "Found debug paths in release build in variable ${_pkg_var}! Path: ${${_pkg_var}}")
                        endif()
                        string(REGEX REPLACE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/\$<\$<CONFIG:DEBUG>:debug/>" _pkg_var_new "${_pkg_var_new}")
                    else()
                        # Release Path found
                        if(CMAKE_BUILD_TYPE MATCHES "^Debug$")
                            vcpkg_msg(WARNING "find_package-fix" "Found release paths in debug build in variable ${_pkg_var}! Path: ${${_pkg_var}}")
                        endif()
                        string(REGEX REPLACE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/\$<\$<CONFIG:DEBUG>:debug/>" _pkg_var_new "${_pkg_var_new}")
                    endif()
                    vcpkg_msg(STATUS "find_package-fix" "Replacing ${_pkg_var}: ${${_pkg_var}}")
                    set(${_pkg_var} "${_pkg_var_new}")
                    vcpkg_msg(STATUS "find_package-fix" "with ${_pkg_var}: ${${_pkg_var}}")
                #else()
                    #if(NOT "${${_pkg_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/" OR "${${_pkg_var}}" STREQUAL "")
                    #    message(STATUS "VCPKG-find_package: ${_pkg_var} does not contain absolute path or is empty! Check: ${${_pkg_var}}")
                    #else()
                    #    message(STATUS "VCPKG-find_package: ${_pkg_var} contains seperate debug and release libraries. Checking correctness of variables!") 
                    #    #check the optimized/debug values for correctness.
                    #    set(_pkg_dbg OFF)
                    #    set(_pkg_rel OFF)
                    #    set(_pkg_var_changed OFF)
                    #    foreach(_pkg_var_elem ${${_pkg_var}})
                    #        if(${_pkg_var_elem} MATCHES "debug")
                    #            set(_pkg_dbg ON)
                    #            list(APPEND _pkg_var_new "${_pkg_var_elem}")
                    #        elseif(${_pkg_var_elem} MATCHES "optimized")
                    #            set(_pkg_rel ON)
                    #            list(APPEND _pkg_var_new "${_pkg_var_elem}")
                    #        elseif(${_pkg_dbg})
                    #            if(NOT "${_pkg_var_elem}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/")
                    #                message(WARNING "VCPKG-Warning-find_package: Found release path after keyword debug.")
                    #                set(_pkg_var_changed ON)
                    #            endif()
                    #            set(_pkg_dbg OFF)
                    #            list(APPEND _pkg_var_new "${_pkg_var_elem}")
                    #        elseif(${_pkg_rel})
                    #             if("${_pkg_var_elem}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/")
                    #                message(WARNING "VCPKG-Warning-find_package: Found debug path after keyword optimized.")
                    #                set(_pkg_var_changed ON)
                    #            endif()
                    #            set(_pkg_rel OFF)
                    #            list(APPEND _pkg_var_new "${_pkg_var_elem}")
                    #        else()
                    #            list(APPEND _pkg_var_new "${_pkg_var_elem}")
                    #        endif()
                    #    endforeach()
                    #    if(${_pkg_var_changed})
                            #TODO: Check if there are packagages which require this check. 
                    #        message(STATUS "VCPKG-find_package: Resetting ${_pkg_var}")
                    #        message(STATUS "VCPKG-find_package: From ${${_pkg_var}}")
                    #        #TODO: Do the change!
                    #        #set(${_pkg_var} "${_pkg_var_new}")
                    #        message(STATUS "VCPKG-find_package: To ${${_pkg_var_new}}")
                    #    endif()
                    #endif()
                endif()
            endforeach()
        endif()
        cmake_policy(POP)
    endif()
endmacro()

if(VCPKG_ENABLE_FIND_PACKAGE)
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