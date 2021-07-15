#[===[.md:
# vcpkg_extract_source_archive_ex

Extract an archive into the source directory.
Originally replaced [`vcpkg_extract_source_archive()`],
but new ports should instead use the second overload of
[`vcpkg_extract_source_archive()`].

## Usage
```cmake
vcpkg_extract_source_archive_ex(
    [OUT_SOURCE_PATH <source_path>]
    ...
)
```

See the documentation for [`vcpkg_extract_source_archive()`] for other parameters.
Additionally, `vcpkg_extract_source_archive_ex()` adds the `REF` and `WORKING_DIRECTORY`
parameters, which are wrappers around `SOURCE_BASE` and `BASE_DIRECTORY`
respectively.

[`vcpkg_extract_source_archive()`]: vcpkg_extract_source_archive.md
#]===]

function(vcpkg_extract_source_archive_ex)
    # OUT_SOURCE_PATH is an out-parameter so we need to parse it
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "OUT_SOURCE_PATH" "")
    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified")
    endif()

    vcpkg_extract_source_archive(source_path ${arg_UNPARSED_ARGUMENTS} Z_ALLOW_OLD_PARAMETER_NAMES)

    set("${arg_OUT_SOURCE_PATH}" "${source_path}" PARENT_SCOPE)
endfunction()
