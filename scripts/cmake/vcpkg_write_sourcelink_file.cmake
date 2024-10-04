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
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "SOURCE_PATH;SERVER_PATH" "")

    if(NOT DEFINED arg_SOURCE_PATH OR NOT DEFINED arg_SERVER_PATH)
        message(FATAL_ERROR "SOURCE_PATH and SERVER_PATH must be specified.")
    endif()

    # Normalize and escape (for JSON) the source path.
    file(TO_NATIVE_PATH "${arg_SOURCE_PATH}" sourcelink_source_path)
    string(REGEX REPLACE "\\\\" "\\\\\\\\" sourcelink_source_path "${sourcelink_source_path}")

    file(WRITE "${CURRENT_PACKAGES_DIR}/sourcelink/${PORT}.json" "{\"documents\":{ \"${sourcelink_source_path}\": \"${arg_SERVER_PATH}\" }}")
endfunction()
