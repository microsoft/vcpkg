#[===[.md:
# vcpkg_extract_source_archive_ex

Extract an archive into the source directory.
Originally replaced `vcpkg_extract_source_archive`,
but new ports should instead use the second overload of
`vcpkg_extract_source_archive`.

## Usage
```cmake
vcpkg_extract_source_archive_ex(
    SKIP_PATCH_CHECK
    OUT_SOURCE_PATH <SOURCE_PATH>
    ARCHIVE <${ARCHIVE}>
    [REF <1.0.0>]
    [NO_REMOVE_ONE_LEVEL]
    [WORKING_DIRECTORY <${CURRENT_BUILDTREES_DIR}/src>]
    [PATCHES <a.patch>...]
)
```
## Parameters
### SKIP_PATCH_CHECK
If this option is set the failure to apply a patch is ignored.

### OUT_SOURCE_PATH
Specifies the out-variable that will contain the extracted location.

This should be set to `SOURCE_PATH` by convention.

### ARCHIVE
The full path to the archive to be extracted.

This is usually obtained from calling [`vcpkg_download_distfile`](vcpkg_download_distfile.md).

### REF
A friendly name that will be used instead of the filename of the archive.  If more than 10 characters it will be truncated.

By convention, this is set to the version number or tag fetched

### WORKING_DIRECTORY
If specified, the archive will be extracted into the working directory instead of `${CURRENT_BUILDTREES_DIR}/src/`.

Note that the archive will still be extracted into a subfolder underneath that directory (`${WORKING_DIRECTORY}/${REF}-${HASH}/`).

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

### NO_REMOVE_ONE_LEVEL
Specifies that the default removal of the top level folder should not occur.

## Examples

* [bzip2](https://github.com/Microsoft/vcpkg/blob/master/ports/bzip2/portfile.cmake)
* [sqlite3](https://github.com/Microsoft/vcpkg/blob/master/ports/sqlite3/portfile.cmake)
* [cairo](https://github.com/Microsoft/vcpkg/blob/master/ports/cairo/portfile.cmake)
#]===]

function(vcpkg_extract_source_archive_ex)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "NO_REMOVE_ONE_LEVEL;SKIP_PATCH_CHECK"
        "OUT_SOURCE_PATH;ARCHIVE;REF;WORKING_DIRECTORY"
        "PATCHES"
    )

    if(NOT DEFINED arg_ARCHIVE)
        message(FATAL_ERROR "ARCHIVE must be specified")
    endif()
    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified")
    endif()

    set(base_directory_param "")
    if(DEFINED arg_WORKING_DIRECTORY)
        cmake_path(IS_PREFIX CURRENT_BUILDTREES_DIR "${arg_WORKING_DIRECTORY}" NORMALIZE is_prefix)
        if(NOT is_prefix)
            message(FATAL_ERROR "WORKING_DIRECTORY must be located under CURRENT_BUILDTREES_DIR:
    WORKING_DIRECTORY     : ${arg_WORKING_DIRECTORY}
    CURRENT_BUILDTREES_DIR: ${CURRENT_BUILDTRESS_DIR}")
        endif()
        cmake_path(RELATIVE_PATH arg_WORKING_DIRECTORY BASE_DIRECTORY "${CURRENT_BUILDTREES_DIR}")
        set(base_directory_param BASE_DIRECTORY "${arg_WORKING_DIRECTORY}")
    endif()

    set(source_base_param "")
    if(DEFINED arg_REF)
        string(REPLACE "/" "-" sanitized_ref "${arg_REF}")
        set(source_base_param SOURCE_BASE "${sanitized_ref}")
    endif()

    set(no_remove_one_level_param "")
    if(NO_REMOVE_ONE_LEVEL)
        set(no_remove_one_level_param NO_REMOVE_ONE_LEVEL)
    endif()
    set(skip_patch_check_param "")
    if(SKIP_PATCH_CHECK)
        set(skip_patch_check_param Z_SKIP_PATCH_CHECK)
    endif()

    vcpkg_extract_source_archive(source_path
        ARCHIVE "${arg_ARCHIVE}"
        PATCHES ${arg_PATCHES}
        ${base_directory_param}
        ${source_base_param}
        ${no_remove_one_level_param}
        ${skip_patch_check_param}
    )

    set(${arg_OUT_SOURCE_PATH} "${source_path}" PARENT_SCOPE)
endfunction()
