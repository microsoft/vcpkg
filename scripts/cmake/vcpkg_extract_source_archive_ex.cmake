#[===[.md:
# vcpkg_extract_source_archive_ex

Extract an archive into the source directory. Replaces [`vcpkg_extract_source_archive`](vcpkg_extract_source_archive.md).

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

include(vcpkg_extract_source_archive)

function(vcpkg_extract_source_archive_ex)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(
        PARSE_ARGV 0
        _vesae
        "NO_REMOVE_ONE_LEVEL;SKIP_PATCH_CHECK"
        "OUT_SOURCE_PATH;ARCHIVE;REF;WORKING_DIRECTORY"
        "PATCHES"
    )

    if(NOT _vesae_ARCHIVE)
        message(FATAL_ERROR "Must specify ARCHIVE parameter to vcpkg_extract_source_archive_ex()")
    endif()

    if(NOT DEFINED _vesae_OUT_SOURCE_PATH)
        message(FATAL_ERROR "Must specify OUT_SOURCE_PATH parameter to vcpkg_extract_source_archive_ex()")
    endif()

    if(NOT DEFINED _vesae_WORKING_DIRECTORY)
        set(_vesae_WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src)
    endif()

    if(NOT DEFINED _vesae_REF)
        get_filename_component(_vesae_REF ${_vesae_ARCHIVE} NAME_WE)
    endif()

    string(REPLACE "/" "-" SANITIZED_REF "${_vesae_REF}")

    # Take the last 10 chars of the REF
    set(REF_MAX_LENGTH 10)
    string(LENGTH ${SANITIZED_REF} REF_LENGTH)
    math(EXPR FROM_REF ${REF_LENGTH}-${REF_MAX_LENGTH})
    if(FROM_REF LESS 0)
        set(FROM_REF 0)
    endif()
    string(SUBSTRING ${SANITIZED_REF} ${FROM_REF} ${REF_LENGTH} SHORTENED_SANITIZED_REF)

    # Hash the archive hash along with the patches. Take the first 10 chars of the hash
    file(SHA512 ${_vesae_ARCHIVE} PATCHSET_HASH)
    foreach(PATCH IN LISTS _vesae_PATCHES)
        get_filename_component(ABSOLUTE_PATCH "${PATCH}" ABSOLUTE BASE_DIR "${CURRENT_PORT_DIR}")
        file(SHA512 ${ABSOLUTE_PATCH} CURRENT_HASH)
        string(APPEND PATCHSET_HASH ${CURRENT_HASH})
    endforeach()

    string(SHA512 PATCHSET_HASH ${PATCHSET_HASH})
    string(SUBSTRING ${PATCHSET_HASH} 0 10 PATCHSET_HASH)
    set(SOURCE_PATH "${_vesae_WORKING_DIRECTORY}/${SHORTENED_SANITIZED_REF}-${PATCHSET_HASH}")
    if (NOT _VCPKG_EDITABLE)
        string(APPEND SOURCE_PATH ".clean")
        if(EXISTS ${SOURCE_PATH})
            message(STATUS "Cleaning sources at ${SOURCE_PATH}. Use --editable to skip cleaning for the packages you specify.")
            file(REMOVE_RECURSE ${SOURCE_PATH})
        endif()
    endif()

    if(NOT EXISTS ${SOURCE_PATH})
        set(TEMP_DIR "${_vesae_WORKING_DIRECTORY}/${SHORTENED_SANITIZED_REF}-${PATCHSET_HASH}.tmp")
        file(REMOVE_RECURSE ${TEMP_DIR})
        vcpkg_extract_source_archive("${_vesae_ARCHIVE}" "${TEMP_DIR}")

        if(_vesae_NO_REMOVE_ONE_LEVEL)
            set(TEMP_SOURCE_PATH ${TEMP_DIR})
        else()
            file(GLOB _ARCHIVE_FILES "${TEMP_DIR}/*")
            list(LENGTH _ARCHIVE_FILES _NUM_ARCHIVE_FILES)
            set(TEMP_SOURCE_PATH)
            foreach(dir IN LISTS _ARCHIVE_FILES)
                if (IS_DIRECTORY ${dir})
                    set(TEMP_SOURCE_PATH "${dir}")
                    break()
                endif()
            endforeach()

            if(NOT _NUM_ARCHIVE_FILES EQUAL 2 OR NOT TEMP_SOURCE_PATH)
                message(FATAL_ERROR "Could not unwrap top level directory from archive. Pass NO_REMOVE_ONE_LEVEL to disable this.")
            endif()
        endif()

        if (_vesae_SKIP_PATCH_CHECK)
            set (QUIET QUIET)
        else()
            set (QUIET)
        endif()

        z_vcpkg_apply_patches(
            ${QUIET}
            SOURCE_PATH ${TEMP_SOURCE_PATH}
            PATCHES ${_vesae_PATCHES}
        )

        file(RENAME ${TEMP_SOURCE_PATH} ${SOURCE_PATH})
        file(REMOVE_RECURSE ${TEMP_DIR})
    endif()

    set(${_vesae_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
    message(STATUS "Using source at ${SOURCE_PATH}")
    return()
endfunction()
