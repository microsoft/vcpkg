#[===[.md:
# vcpkg_from_git

Download and extract a project from git

## Usage:
```cmake
vcpkg_from_git(
    OUT_SOURCE_PATH <SOURCE_PATH>
    URL <https://android.googlesource.com/platform/external/fdlibm>
    REF <59f7335e4d...>
    [HEAD_REF <ref>]
    [PATCHES <patch1.patch> <patch2.patch>...]
)
```

## Parameters:
### OUT_SOURCE_PATH
Specifies the out-variable that will contain the extracted location.

This should be set to `SOURCE_PATH` by convention.

### URL
The url of the git repository.

### REF
The git sha of the commit to download.

### HEAD_REF
The git branch to use when the package is requested to be built from the latest sources.

Example: `main`, `develop`, `HEAD`

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

## Notes:
`OUT_SOURCE_PATH`, `REF`, and `URL` must be specified.

## Examples:

* [fdlibm](https://github.com/Microsoft/vcpkg/blob/master/ports/fdlibm/portfile.cmake)
#]===]

include(vcpkg_execute_in_download_mode)

function(vcpkg_from_git)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;URL;REF;HEAD_REF;TAG"
        "PATCHES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_git was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(DEFINED arg_TAG)
        message(WARNING "The TAG argument to vcpkg_from_git has been deprecated and has no effect.")
    endif()
    

    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()
    if(NOT DEFINED arg_URL)
        message(FATAL_ERROR "The git url must be specified")
    endif()
    if(NOT DEFINED arg_REF AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "At least one of REF or HEAD_REF must be specified.")
    endif()

    set(working_directory_param "")
    set(ref_to_use "${arg_REF}")
    if(VCPKG_USE_HEAD_VERSION)
        if(DEFINED arg_HEAD_REF)
            set(working_directory_param "WORKING_DIRECTORY" "${CURRENT_BUILDTREES_DIR}/src/head")
            set(ref_to_use "${arg_HEAD_REF}")
        else()
            message(STATUS "Package does not specify HEAD_REF. Falling back to non-HEAD version.")
        endif()
    elseif(NOT DEFINED arg_REF)
        message(FATAL_ERROR "Package does not specify REF. It must be built using --head.")
    endif()

    string(REPLACE "/" "_-" sanitized_ref "${ref_to_use}")
    set(temp_archive "${DOWNLOADS}/temp/${PORT}-${sanitized_ref}.tar.gz")
    set(archive "${DOWNLOADS}/${PORT}-${sanitized_ref}.tar.gz")

    if(NOT EXISTS "${archive}")
        if(_VCPKG_NO_DOWNLOADS)
            message(FATAL_ERROR "Downloads are disabled, but '${archive}' does not exist.")
        endif()
        message(STATUS "Fetching ${arg_URL} ${ref_to_use}...")
        find_program(GIT NAMES git git.cmd)
        file(MAKE_DIRECTORY "${DOWNLOADS}")
        # Note: git init is safe to run multiple times
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${GIT}" init git-tmp
            WORKING_DIRECTORY "${DOWNLOADS}"
            LOGNAME "git-init-${TARGET_TRIPLET}"
        )
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${GIT}" fetch "${arg_URL}" "${ref_to_use}" --depth 1 -n
            WORKING_DIRECTORY "${DOWNLOADS}/git-tmp"
            LOGNAME "git-fetch-${TARGET_TRIPLET}"
        )
        vcpkg_execute_in_download_mode(
            COMMAND "${GIT}" rev-parse FETCH_HEAD
            OUTPUT_VARIABLE rev_parse_head
            ERROR_VARIABLE rev_parse_head
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY "${DOWNLOADS}/git-tmp"
        )
        if(error_code)
            message(FATAL_ERROR "unable to determine FETCH_HEAD after fetching git repository")
        endif()
        string(STRIP "${rev_parse_head}" rev_parse_head)
        if(VCPKG_USE_HEAD_VERSION)
            set(VCPKG_HEAD_VERSION "${rev_parse_head}" PARENT_SCOPE)
        elseif(NOT rev_parse_head STREQUAL arg_REF)
            message(FATAL_ERROR "REF (${arg_REF}) does not match FETCH_HEAD (${rev_parse_head})
    [Expected : ( ${arg_REF} )])
    [  Actual : ( ${rev_parse_head} )]"
            )
        endif()

        file(MAKE_DIRECTORY "${DOWNLOADS}/temp")
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${GIT}" archive "${rev_parse_head}" -o "${temp_archive}"
            WORKING_DIRECTORY "${DOWNLOADS}/git-tmp"
            LOGNAME git-archive
        )
        file(RENAME "${temp_archive}" "${archive}")
    else()
        message(STATUS "Using cached ${archive}")
    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${archive}"
        REF "${sanitized_ref}"
        PATCHES ${arg_PATCHES}
        NO_REMOVE_ONE_LEVEL
        ${working_directory_param}
    )

    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
