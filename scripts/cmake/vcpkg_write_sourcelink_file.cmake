#[===[.md:
# vcpkg_write_sourcelink_file

Write a Source Link file (if enabled). Internal function not for direct use by ports.

## Usage:
```cmake
vcpkg_write_sourcelink_file(
     SOURCE_PATH <path>
     SERVER_PATH <URL>
)
```

## Parameters:
### SOURCE_PATH
Specifies the local location of the sources used for build.

### SERVER_PATH
Specified the permanent location of the corresponding sources.
#]===]


function(vcpkg_write_sourcelink_file)
    cmake_parse_arguments(_vwsf "" "SOURCE_PATH;SERVER_PATH" "" ${ARGN})

    if(NOT DEFINED _vwsf_SOURCE_PATH OR NOT DEFINED _vwsf_SERVER_PATH)
        message(FATAL_ERROR "SOURCE_PATH and SERVER_PATH must be specified.")
    endif()

    # Normalize and escape (for JSON) the source path.
    file(TO_NATIVE_PATH "${_vwsf_SOURCE_PATH}" SOURCELINK_SOURCE_PATH)
    string(REGEX REPLACE "\\\\" "\\\\\\\\" SOURCELINK_SOURCE_PATH "${SOURCELINK_SOURCE_PATH}")

    file(WRITE "${CURRENT_PACKAGES_DIR}/sourcelink/${PORT}.json" "{\"documents\":{ \"${SOURCELINK_SOURCE_PATH}\": \"${_vwsf_SERVER_PATH}\" }}")
endfunction()
