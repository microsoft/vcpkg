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
        set(_cbo_found -1)
        if("${cbo_file}" MATCHES "-rel-") #Release Output
            string(FIND "${_cbo_contents}" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" _cbo_found)
        elseif("${cbo_file}" MATCHES "-dbg-") #Debug Output
            string(FIND "${_cbo_contents}" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" _cbo_found)
        else()
            message(FATAL_ERROR "VCPKG-check-build-output:${cbo_file} does not contain string -rel- or -dbg-. Cannot automatically determine target configuration!")
        endif()
        
        if(NOT ${_cbo_found} EQUAL -1)
            message(FATAL_ERROR "VCPKG-check-build-output: Found wrong path in build output: file:${dbg_file} line:${_cbo_dbg_found}! Please investigate and fix library linkage")
        else()
            message(STATUS "VCPKG-check-build-output: Library linkage checked!")
            #message(STATUS "${_cbo_contents}")
        endif()
    endforeach()
endfunction()