## # vcpkg_prettify_command
##
## Turns list of command arguments into a formatted string.
##
## ## Usage
## ```cmake
## vcpkg_prettify_command(<INPUT_VAR> <OUTPUT_VAR>)
## ```
##
## ## Examples
##
## * `scripts/cmake/vcpkg_execute_build_process.cmake`
## * `scripts/cmake/vcpkg_execute_required_process.cmake`
## * `scripts/cmake/vcpkg_execute_required_process_repeat.cmake`

macro(vcpkg_prettify_command INPUT_VAR OUTPUT_VAR)
    set(${OUTPUT_VAR} "")
    foreach(v ${${INPUT_VAR}})
        if(v MATCHES "( )")
            list(APPEND ${OUTPUT_VAR} "\"${v}\"")
        else()
            list(APPEND ${OUTPUT_VAR} "${v}")
        endif()
    endforeach()
    list(JOIN ${OUTPUT_VAR} " " ${OUTPUT_VAR})
endmacro()
