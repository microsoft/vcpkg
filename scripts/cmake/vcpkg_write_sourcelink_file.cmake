#[===[.md:
# vcpkg_write_sourcelink_file

Write a Source Link file (if enabled). Internal function not for direct use by ports.

## Usage:
```cmake
vcpkg_write_sourcelink_file(
     SOURCE_PATH <path>
     SERVER_PATH <URL>
     RAW_INCLUDE_MAPPING <list_of_mapping_pairs>
)
```

## Parameters:
### SOURCE_PATH
Specifies the local location of the sources used for build.

### SERVER_PATH
Specified the permanent location of the corresponding sources.

### RAW_INCLUDE_MAPPING
Mapping of installed headers to the raw repo paths, which allows identification of inlined code from those headers.
This is optional - if not specified, then these entries will not be added.

Each mapping consists of a pair of strings, which are then embedded into the file after some formatting.
- First string is *from*, which represents the path below the `include` folder after installation
- Second string is *to*, which represents the path below the source repo.

As per the SourceLink spec, each location may include 0 or 1 wildcard character, and they must be a matched set (both or neither contain it).

Note that this is only used after the headers are installed into the target location for downstream consumption,
not during the build of the port itself.  Therefore the on-disk location includes a
placeholder of `__VCPKG_INSTALLED_TRIPLET_DIR__` that is expected to be replaced before including this
into the target sourcelink.  It's harmless to have it included intermediate builds,
because none of the embedded paths will match to that prefix.

Common patterns include:
```cmake
    list(APPEND raw_include_mapping "${PORT}/*" "*")
    list(APPEND raw_include_mapping "${PORT}/*" "include/${repo_name}/*")
```

This also allows individual files to be overridden, even the uncommon situation of files directly inside the include directory.
```cmake
    list(APPEND raw_include_mapping "${PORT}/myfile.h" "special/myfile.h")
    list(APPEND raw_include_mapping "${PORT}.h" "${PORT}.h")
```

#]===]


function(vcpkg_write_sourcelink_file)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "SOURCE_PATH;SERVER_PATH;RAW_INCLUDE_MAPPING" "")

    if(NOT DEFINED arg_SOURCE_PATH OR NOT DEFINED arg_SERVER_PATH)
        message(FATAL_ERROR "SOURCE_PATH and SERVER_PATH must be specified.")
    endif()

    # Normalize and escape (for JSON) the source path.
    file(TO_NATIVE_PATH "${arg_SOURCE_PATH}" sourcelink_source_path)
    string(REGEX REPLACE "\\\\" "\\\\\\\\" sourcelink_source_path "${sourcelink_source_path}")

    # Write the first line of the file, which is used for the immediate build of this port
    file(WRITE "${CURRENT_PACKAGES_DIR}/sourcelink/${PORT}.json" "{\"documents\":{ \"${sourcelink_source_path}\": \"${arg_SERVER_PATH}\"")

    # If specified, add the mappings
    if (DEFINED arg_RAW_INCLUDE_MAPPING)
        list(LENGTH arg_RAW_INCLUDE_MAPPING num_mappings)
        foreach(i RANGE 0 ${num_mappings} 2)
            if (${i}+1 LESS ${num_mappings})
                list(POP_FRONT arg_RAW_INCLUDE_MAPPING item_from item_to)

                file(TO_NATIVE_PATH "__VCPKG_INSTALLED_TRIPLET_DIR__/include/${item_from}" adjusted_item_from)
                string(REGEX REPLACE "\\\\" "\\\\\\\\" adjusted_item_from "${adjusted_item_from}")

                # SourceLink strings are allows to have either 0 or 1 wildcards, so a simple replace is suitable.
                string(REPLACE "*" "${item_to}" adjusted_item_to "${arg_SERVER_PATH}")

                file(APPEND "${CURRENT_PACKAGES_DIR}/sourcelink/${PORT}.json" ", \"${adjusted_item_from}\": \"${adjusted_item_to}\"")
            endif()
        endforeach()
    endif()

    # Append the closing braces the the file
    file(APPEND "${CURRENT_PACKAGES_DIR}/sourcelink/${PORT}.json" "}}")

endfunction()
