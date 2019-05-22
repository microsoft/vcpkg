## # vcpkg_check_build_output
##
## Check Build Output for library linkage.
## Logfiles must contain -dbg- or -rel-
##
## ## Usage:
## ```cmake
## vcpkg_check_build_output(LOGFILES file1 [file2 ...])
## ```
##
## ## Parameters:
## ### LOGFILES
## Output build files to check for linkage
##
##
## ## Notes:
## This command should be used after a call to any build command. 
## Will throw a fatal error if a library release/debug library is 
## linked against a debug/release library.
##
function(vcpkg_check_build_output)
    cmake_parse_arguments(_cbo "" "" "LOGFILES" ${ARGN})    
    #Check build outputs
    foreach(cbo_file IN LISTS _cbo_LOGFILES)
        file(READ "${cbo_file}" _cbo_contents)
        #set(_cbo_found -1)
        message(STATUS "VCPKG-check-build-output: Checking library linkage from log: ${cbo_file}")
        if("${cbo_file}" MATCHES "-rel-") #Release Output
            set(_vcpkg_check_searchpath "${CURRENT_INSTALLED_DIR}/debug/lib")
        elseif("${cbo_file}" MATCHES "-dbg-") #Debug Output
            set(_vcpkg_check_searchpath "${CURRENT_INSTALLED_DIR}/lib")
        else()
            message(FATAL_ERROR "VCPKG-check-build-output:${cbo_file} does not contain string -rel- or -dbg-. Cannot automatically determine target configuration!")
        endif()
        
        if(WIN32)
            string(REPLACE "/" "\\" _vcpkg_check_searchpath ${_vcpkg_check_searchpath})
        endif()
        message(STATUS "VCPKG-check-build-output: Searching for invalid ${_vcpkg_check_searchpath}")
        string(FIND "${_cbo_contents}" "${_vcpkg_check_searchpath}" _cbo_found)
        
        if(NOT ${_cbo_found} EQUAL -1)
            message(FATAL_ERROR "VCPKG-check-build-output: Found wrong path in build output: file:${cbo_file} line:${_cbo_found}! Please investigate and fix library linkage")
        else()
            message(STATUS "VCPKG-check-build-output: Library linkage checked!")
            #message(STATUS "${_cbo_contents}")
        endif()
    endforeach()
endfunction()