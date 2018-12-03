## # vcpkg_write_sourcelink_file
##
## Write a Source Link file (if enabled).
##
## ## Usage:
## ```cmake
## vcpkg_write_sourcelink_file(
##      SOURCE_PATH <path>
##      SERVER_PATH <URL>
## )
## ```
##
## ## Parameters:
## ### SOURCE_PATH
## Specifies the local location of the sources used for build.
##
## ### SERVER_PATH
## Specified the permanent location of the corresponding sources.
##
function(vcpkg_write_sourcelink_file)
    set(oneValueArgs SOURCE_PATH SERVER_PATH)
    set(multipleValuesArgs)
    cmake_parse_arguments(_vwsf "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

    if(NOT DEFINED _vwsf_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified.")
    endif()

    if(VCPKG_ENABLE_SOURCE_LINK)
        # Normalize and escape (for JSON) the source path.
        file(TO_NATIVE_PATH "${_vwsf_SOURCE_PATH}" SOURCELINK_SOURCE_PATH)
        string(REGEX REPLACE "\\\\" "\\\\\\\\" SOURCELINK_SOURCE_PATH "${SOURCELINK_SOURCE_PATH}")

        file(WRITE  "${CURRENT_SOURCELINK_FILE}" "{\"documents\":{\n")
        file(APPEND "${CURRENT_SOURCELINK_FILE}" "  \"${SOURCELINK_SOURCE_PATH}\": \"${_vwsf_SERVER_PATH}\"\n")
        file(APPEND "${CURRENT_SOURCELINK_FILE}" "}}")
    endif()
endfunction()
