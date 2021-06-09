#[===[.md:
# vcpkg_from_github

Download and extract a project from GitHub. Enables support for `install --head`.

## Usage:
```cmake
vcpkg_from_github(
    OUT_SOURCE_PATH <SOURCE_PATH>
    REPO <Microsoft/cpprestsdk>
    [REF <v2.0.0>]
    [SHA512 <45d0d7f8cc350...>]
    [HEAD_REF <master>]
    [PATCHES <patch1.patch> <patch2.patch>...]
    [GITHUB_HOST <https://github.com>]
    [AUTHORIZATION_TOKEN <${SECRET_FROM_FILE}>]
    [FILE_DISAMBIGUATOR <N>]
)
```

## Parameters:
### OUT_SOURCE_PATH
Specifies the out-variable that will contain the extracted location.

This should be set to `SOURCE_PATH` by convention.

### REPO
The organization or user and repository on GitHub.

### REF
A stable git commit-ish (ideally a tag or commit) that will not change contents. **This should not be a branch.**

For repositories without official releases, this can be set to the full commit id of the current latest master.

If `REF` is specified, `SHA512` must also be specified.

### SHA512
The SHA512 hash that should match the archive (https://github.com/${REPO}/archive/${REF}.tar.gz).

This is most easily determined by first setting it to `1`, then trying to build the port. The error message will contain the full hash, which can be copied back into the portfile.

### HEAD_REF
The unstable git commit-ish (ideally a branch) to pull for `--head` builds.

For most projects, this should be `master`. The chosen branch should be one that is expected to be always buildable on all supported platforms.

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

### GITHUB_HOST
A replacement host for enterprise GitHub instances.

This field should contain the scheme, host, and port of the desired URL without a trailing slash.

### AUTHORIZATION_TOKEN
A token to be passed via the Authorization HTTP header as "token ${AUTHORIZATION_TOKEN}".

### FILE_DISAMBIGUATOR
A token to uniquely identify the resulting filename if the SHA512 changes even though a git ref does not, to avoid stepping on the same file name.

## Notes:
At least one of `REF` and `HEAD_REF` must be specified, however it is preferable for both to be present.

This exports the `VCPKG_HEAD_VERSION` variable during head builds.

## Examples:

* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [ms-gsl](https://github.com/Microsoft/vcpkg/blob/master/ports/ms-gsl/portfile.cmake)
* [boost-beast](https://github.com/Microsoft/vcpkg/blob/master/ports/boost-beast/portfile.cmake)
#]===]

function(vcpkg_from_github)
    set(oneValueArgs OUT_SOURCE_PATH REPO REF SHA512 HEAD_REF GITHUB_HOST AUTHORIZATION_TOKEN FILE_DISAMBIGUATOR)
    set(multipleValuesArgs PATCHES)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _vdud "" "${oneValueArgs}" "${multipleValuesArgs}")

    if(NOT DEFINED _vdud_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()

    if((DEFINED _vdud_REF AND NOT DEFINED _vdud_SHA512) OR (NOT DEFINED _vdud_REF AND DEFINED _vdud_SHA512))
        message(FATAL_ERROR "SHA512 must be specified if REF is specified.")
    endif()

    if(NOT DEFINED _vdud_REPO)
        message(FATAL_ERROR "The GitHub repository must be specified.")
    endif()

    if(NOT DEFINED _vdud_REF AND NOT DEFINED _vdud_HEAD_REF)
        message(FATAL_ERROR "At least one of REF and HEAD_REF must be specified.")
    endif()

    if(NOT DEFINED _vdud_GITHUB_HOST)
        set(GITHUB_HOST https://github.com)
        set(GITHUB_API_URL https://api.github.com)
    else()
        set(GITHUB_HOST "${_vdud_GITHUB_HOST}")
        set(GITHUB_API_URL "${_vdud_GITHUB_HOST}/api/v3")
    endif()

    if(DEFINED _vdud_AUTHORIZATION_TOKEN)
        set(HEADERS "HEADERS" "Authorization: token ${_vdud_AUTHORIZATION_TOKEN}")
    else()
        set(HEADERS)
    endif()

    string(REGEX REPLACE ".*/" "" REPO_NAME "${_vdud_REPO}")
    string(REGEX REPLACE "/.*" "" ORG_NAME "${_vdud_REPO}")

    macro(set_TEMP_SOURCE_PATH BASE BASEREF)
        set(TEMP_SOURCE_PATH "${BASE}/${REPO_NAME}-${BASEREF}")
        if(NOT EXISTS "${TEMP_SOURCE_PATH}")
            # Sometimes GitHub strips a leading 'v' off the REF.
            string(REGEX REPLACE "^v" "" REF "${BASEREF}")
            string(REPLACE "/" "-" REF "${REF}")
            set(TEMP_SOURCE_PATH "${BASE}/${REPO_NAME}-${REF}")
            if(NOT EXISTS "${TEMP_SOURCE_PATH}")
                message(FATAL_ERROR "Could not determine source path: '${BASE}/${REPO_NAME}-${BASEREF}' does not exist")
            endif()
        endif()
    endmacro()

    if(VCPKG_USE_HEAD_VERSION AND NOT DEFINED _vdud_HEAD_REF)
        message(STATUS "Package does not specify HEAD_REF. Falling back to non-HEAD version.")
        set(VCPKG_USE_HEAD_VERSION OFF)
    endif()

    # Handle --no-head scenarios
    if(NOT VCPKG_USE_HEAD_VERSION)
        if(NOT _vdud_REF)
            message(FATAL_ERROR "Package does not specify REF. It must built using --head.")
        endif()

        string(REPLACE "/" "-" SANITIZED_REF "${_vdud_REF}")

        set(downloaded_file_name "${ORG_NAME}-${REPO_NAME}-${SANITIZED_REF}")
        if (_vdud_FILE_DISAMBIGUATOR)
            set(downloaded_file_name "${downloaded_file_name}-${_vdud_FILE_DISAMBIGUATOR}")
        endif()

        set(downloaded_file_name "${downloaded_file_name}.tar.gz")

        vcpkg_download_distfile(ARCHIVE
            URLS "${GITHUB_HOST}/${ORG_NAME}/${REPO_NAME}/archive/${_vdud_REF}.tar.gz"
            SHA512 "${_vdud_SHA512}"
            FILENAME "${downloaded_file_name}"
            ${HEADERS}
        )

        vcpkg_extract_source_archive_ex(
            OUT_SOURCE_PATH SOURCE_PATH
            ARCHIVE "${ARCHIVE}"
            REF "${SANITIZED_REF}"
            PATCHES ${_vdud_PATCHES}
        )

        set(${_vdud_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
        return()
    endif()

    # The following is for --head scenarios
    set(URL "${GITHUB_HOST}/${ORG_NAME}/${REPO_NAME}/archive/${_vdud_HEAD_REF}.tar.gz")
    string(REPLACE "/" "-" SANITIZED_HEAD_REF "${_vdud_HEAD_REF}")
    set(downloaded_file_name "${ORG_NAME}-${REPO_NAME}-${SANITIZED_HEAD_REF}")
    if (_vdud_FILE_DISAMBIGUATOR)
        set(downloaded_file_name "${downloaded_file_name}-${_vdud_FILE_DISAMBIGUATOR}")
    endif()

    set(downloaded_file_name "${downloaded_file_name}.tar.gz")

    set(downloaded_file_path "${DOWNLOADS}/${downloaded_file_name}")

    if(_VCPKG_NO_DOWNLOADS)
        if(NOT EXISTS "${downloaded_file_path}" OR NOT EXISTS "${downloaded_file_path}.version")
            message(FATAL_ERROR "Downloads are disabled, but '${downloaded_file_path}' does not exist.")
        endif()
        message(STATUS "Using cached ${downloaded_file_path}")
    else()
        if(EXISTS "${downloaded_file_path}")
            message(STATUS "Purging cached ${downloaded_file_path} to fetch latest (use --no-downloads to suppress)")
            file(REMOVE "${downloaded_file_path}")
        endif()
        if(EXISTS "${downloaded_file_path}.version")
            file(REMOVE "${downloaded_file_path}.version")
        endif()
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/src/head")
            file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/src/head")
        endif()

        # Try to download the file and version information from github.
        vcpkg_download_distfile(ARCHIVE_VERSION
            URLS "${GITHUB_API_URL}/repos/${ORG_NAME}/${REPO_NAME}/git/refs/heads/${_vdud_HEAD_REF}"
            FILENAME "${downloaded_file_name}.version"
            SKIP_SHA512
            ${HEADERS}
        )

        vcpkg_download_distfile(ARCHIVE
            URLS ${URL}
            FILENAME "${downloaded_file_name}"
            SKIP_SHA512
            ${HEADERS}
        )
    endif()

    # Parse the github refs response with regex.
    # TODO: use some JSON swiss-army-knife utility instead.
    file(READ "${downloaded_file_path}.version" _contents)
    string(REGEX MATCH "\"sha\": \"[a-f0-9]+\"" x "${_contents}")
    string(REGEX REPLACE "\"sha\": \"([a-f0-9]+)\"" "\\1" _version ${x})

    # exports VCPKG_HEAD_VERSION to the caller. This will get picked up by ports.cmake after the build.
    # When multiple vcpkg_from_github's are used after each other, only use the version from the first (hopefully the primary one).
    if(NOT DEFINED VCPKG_HEAD_VERSION)
        set(VCPKG_HEAD_VERSION "${_version}" PARENT_SCOPE)
    endif()

    vcpkg_extract_source_archive_ex(
        SKIP_PATCH_CHECK
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${downloaded_file_path}"
        REF "${SANITIZED_HEAD_REF}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/head"
        PATCHES ${_vdud_PATCHES}
    )
    set(${_vdud_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
