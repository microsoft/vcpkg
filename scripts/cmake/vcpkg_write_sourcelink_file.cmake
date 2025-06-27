#[===[.md:
# vcpkg_write_sourcelink_file

Write a Source Link file (if enabled). Internal function not for direct use by ports.

## Usage:
```cmake
vcpkg_write_sourcelink_file(
     SOURCE_PATH <path>
     SERVER_PATH <URL>
     RAW_SEARCH_REPO_NAME <repo_name>
     RAW_INCLUDE_MAPPING <list_of_mapping_pairs>
)
```

## Parameters:
### SOURCE_PATH
Specifies the local location of the sources used for build.

### SERVER_PATH
Specified the permanent location of the corresponding sources.

### RAW_SEARCH_REPO_NAME
Repo subdirectory name to use during include-mapping search, if no RAW_INCLUDE_MAPPING is provided.
This is used to check for the existence of some directories below SOURCE_PATH,
such as `include/${RAW_SEARCH_REPO_NAME}/`

### RAW_INCLUDE_MAPPING
Mapping of installed headers to the raw repo paths, which allows identification of inlined code from those headers.
This is optional - if not specified, then an automatic entry will be added after inspecting the extracted directories below SOURCE_PATH.

Each mapping consists of a pair of strings, which are then embedded into the file after some formatting.
- First string is *from*, which represents the path below the `include` folder after installation
- Second string is *to*, which represents the path below the source repo.

As per the SourceLink spec, each location may include 0 or 1 wildcard character, and they must be a matched set (both or neither contain it).

Note that this is only used after the headers are installed into the target location for downstream consumption,
not during the build of the port itself.  Therefore the on-disk location includes a
placeholder of `__VCPKG_INSTALLED_TRIPLET_DIR__` that is expected to be replaced before including this
into the target sourcelink.  It's harmless to have it included intermediate builds,
because none of the embedded paths will match to that prefix.

It is critical that the `from` paths are globally unique, because they are used as keys in the JSON file.
Hence, these typically start with the port name (as installed under `include/`), except in rare cases where individual header names are specified.

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

## Resulting output:
Below is a sample output from the `fmt` project that illustrates several things:
- The first entry represents the build-time location of the port itself.
  - This is critical for debugging into the library itself, and only depends on the SERVER_PATH being valid
  - If a Shared library is produced, then this is embedded into the PDB (on Windows)
  - If a Static library is produced, then the JSON will be embedded in the eventual executable or shared library that uses it
- The remaining entries are prefixed with `__VCPKG_INSTALLED_TRIPLET_DIR__`, which serves as a placeholder
  - As illustrated below, when headers are installed into the target location, they are relocated from their original location within the repository.
    - See the optional RAW_INCLUDE_MAPPING parameter
  - These must be substituted when incorporating this into a target build with the combination of VCPKG_INSTALLED_DIR and VCPKG_TARGET_TRIPLET
    - See `vcpkg_add_sourcelink_link_options` in `buildsystems/vcpkg.cmake` for one example of how these can be prepared for use
  - If no substitution is done, then these embedded paths are harmlessly ignored by the eventual consumer because none of the embedded filenames actually start with the string `__VCPKG_INSTALLED_TRIPLET_DIR__`

```json
{"documents":{ 
 "D:\\mydev\\vcpkg\\buildtrees\\fmt\\src\\10.2.1-a991065f88.clean\\*": "https://raw.githubusercontent.com/fmtlib/fmt/10.2.1/*",
 "__VCPKG_INSTALLED_TRIPLET_DIR__\\include\\fmt\\*": "https://raw.githubusercontent.com/fmtlib/fmt/10.2.1/include/fmt/*"
}}
```

#]===]


function(vcpkg_write_sourcelink_file)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "SOURCE_PATH;SERVER_PATH;RAW_SEARCH_REPO_NAME;RAW_INCLUDE_MAPPING" "")

    if(NOT DEFINED arg_SOURCE_PATH OR NOT DEFINED arg_SERVER_PATH)
        message(FATAL_ERROR "SOURCE_PATH and SERVER_PATH must be specified.")
    endif()

    if(DEFINED arg_RAW_INCLUDE_MAPPING AND NOT "${arg_RAW_INCLUDE_MAPPING}" STREQUAL "")
        # If the port provides these string pairs, then use them directly without further validation.
        set(raw_include_mapping "${arg_RAW_INCLUDE_MAPPING}")
    else()
        # Establish a sensible default if none was provided by searching the extracted source.
        # Because this is represented as JSON key/value pairs, there can be only one entry per key.
        #
        # Note:
        # - The FIRST string (key) *always* starts with the port name, which is the local
        #   location of the headers during builds.  This is used during debugging to map filenames
        #   embedded in the PDB or other debug files.
        #     (This is always prefixed with `include/` when the file is written)
        # - The SECOND string (value) is appended to the git repository RAW file URL, which is the permanent
        #   location of the identified files in the repo.
        #
        # For example if `src` is found in the local clone, then the mapping will look like:
        #   From:
        #     (INSTALLED_TRIPLET)\include\${PORT}\* 
        #   To:
        #     (SERVER_PATH)/include/src/*

        # The checks that include the repo name only make sense if it's populated
        if (DEFINED arg_RAW_SEARCH_REPO_NAME AND NOT "${arg_RAW_SEARCH_REPO_NAME}" STREQUAL "")
            set(check_repo_name True)
        endif()

        # The order is relevant here, so the most deply-nested items or most interesting are found first
        if(check_repo_name AND IS_DIRECTORY "${arg_SOURCE_PATH}/include/${arg_RAW_SEARCH_REPO_NAME}")
            list(APPEND raw_include_mapping "${PORT}/*" "include/${arg_RAW_SEARCH_REPO_NAME}/*")
        elseif(IS_DIRECTORY  "${arg_SOURCE_PATH}/include")
            list(APPEND raw_include_mapping "${PORT}/*" "include/*")
        elseif(check_repo_name AND IS_DIRECTORY "${arg_SOURCE_PATH}/${arg_RAW_SEARCH_REPO_NAME}")
            list(APPEND raw_include_mapping "${PORT}/*" "${arg_RAW_SEARCH_REPO_NAME}/*")
        elseif(IS_DIRECTORY  "${arg_SOURCE_PATH}/src")
            list(APPEND raw_include_mapping "${PORT}/*" "src/*")
        elseif(IS_DIRECTORY  "${arg_SOURCE_PATH}/source")
            list(APPEND raw_include_mapping "${PORT}/*" "source/*")
        endif()

        # If the common patterns above do not find any matching directories, then the mapping for installed headers
        # will be omitted. While it is possible to have a fallback mapping to the top of the repo from include/${PORT}/,
        # it was not found to be useful in practice. 
        #    list(APPEND raw_include_mapping "${PORT}/*" "*")
        # 
        # Port maintainers are encouraged to provide suitable mappings via RAW_INCLUDE_MAPPING as needed.

    endif()

    # Normalize and escape (for JSON) the source path.
    # - Adding the '*' wildcard explicitly here because we are passed the plain SOURCE_PATH
    # - Both here and below, the path formatting handles either native path format
    #   by creating the initial path with forward-slash, converting to native,
    #   and then escaping any backslashes (if they are present)
    file(TO_NATIVE_PATH "${arg_SOURCE_PATH}/*" sourcelink_source_path)
    string(REGEX REPLACE "\\\\" "\\\\\\\\" sourcelink_source_path "${sourcelink_source_path}")

    # Write the first line of the file, which is used for the immediate build of this port
    # - These paths are fully known because the buildtree is directly using the original repo
    #   contents when the port is built directly from the local source.
    # - Of course if any local patches or modifications are applied, then the file hashes will never
    #   match exactly.. but that is beyond the scope of this automatic sourcelink mechanism.
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/sourcelink/${PORT}.json" "{\"documents\":{ \"${sourcelink_source_path}\": \"${arg_SERVER_PATH}\"")

    # If specified, add the mappings
    if (DEFINED raw_include_mapping)
        list(LENGTH raw_include_mapping num_mappings)
        foreach(i RANGE 0 ${num_mappings} 2)
            if (${i}+1 LESS ${num_mappings})
                list(POP_FRONT raw_include_mapping item_from item_to)

                file(TO_NATIVE_PATH "__VCPKG_INSTALLED_TRIPLET_DIR__/include/${item_from}" adjusted_item_from)
                string(REGEX REPLACE "\\\\" "\\\\\\\\" adjusted_item_from "${adjusted_item_from}")

                # SourceLink strings are allowed to have either 0 or 1 wildcards, so a simple replace is suitable.
                string(REPLACE "*" "${item_to}" adjusted_item_to "${arg_SERVER_PATH}")

                file(APPEND "${CURRENT_PACKAGES_DIR}/share/sourcelink/${PORT}.json" ", \"${adjusted_item_from}\": \"${adjusted_item_to}\"")
            endif()
        endforeach()
    endif()

    # Append the closing braces the the file
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/sourcelink/${PORT}.json" "}}")

endfunction()
