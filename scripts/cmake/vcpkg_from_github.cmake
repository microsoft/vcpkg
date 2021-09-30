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

This is most easily determined by first setting it to `0`, then trying to build the port. The error message will contain the full hash, which can be copied back into the portfile.

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
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;REPO;REF;SHA512;HEAD_REF;GITHUB_HOST;AUTHORIZATION_TOKEN;FILE_DISAMBIGUATOR"
        "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_github was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(DEFINED arg_REF AND NOT DEFINED arg_SHA512)
        message(FATAL_ERROR "SHA512 must be specified if REF is specified.")
    endif()
    if(NOT DEFINED arg_REF AND DEFINED arg_SHA512)
        message(FATAL_ERROR "REF must be specified if SHA512 is specified.")
    endif()

    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()
    if(NOT DEFINED arg_REPO)
        message(FATAL_ERROR "The GitHub repository must be specified.")
    endif()

    if(NOT DEFINED arg_GITHUB_HOST)
        set(github_host "https://github.com")
        set(github_api_url "https://api.github.com")
    else()
        set(github_host "${arg_GITHUB_HOST}")
        set(github_api_url "${arg_GITHUB_HOST}/api/v3")
    endif()

    set(headers_param "")
    if(DEFINED arg_AUTHORIZATION_TOKEN)
        set(headers_param "HEADERS" "Authorization: token ${arg_AUTHORIZATION_TOKEN}")
    endif()


    if(NOT DEFINED arg_REF AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "At least one of REF or HEAD_REF must be specified.")
    endif()

    if(NOT arg_REPO MATCHES "^([^/]*)/([^/]*)$")
        message(FATAL_ERROR "REPO (${arg_REPO}) is not a valid repo name:
    must be an organization name followed by a repository name separated by a single slash.")
    endif()
    set(org_name "${CMAKE_MATCH_1}")
    set(repo_name "${CMAKE_MATCH_2}")

    set(redownload_param "")
    set(working_directory_param "")
    set(sha512_param "SHA512" "${arg_SHA512}")
    set(ref_to_use "${arg_REF}")
    if(VCPKG_USE_HEAD_VERSION)
        if(DEFINED arg_HEAD_REF)
            set(redownload_param "ALWAYS_REDOWNLOAD")
            set(sha512_param "SKIP_SHA512")
            set(working_directory_param "WORKING_DIRECTORY" "${CURRENT_BUILDTREES_DIR}/src/head")
            set(ref_to_use "${arg_HEAD_REF}")
        else()
            message(STATUS "Package does not specify HEAD_REF. Falling back to non-HEAD version.")
        endif()
    elseif(NOT DEFINED arg_REF)
        message(FATAL_ERROR "Package does not specify REF. It must be built using --head.")
    endif()

    # avoid using either - or _, to allow both `foo/bar` and `foo-bar` to coexist
    # we assume that no one will name a ref "foo_-bar"
    string(REPLACE "/" "_-" sanitized_ref "${ref_to_use}")
    if(DEFINED arg_FILE_DISAMBIGUATOR AND NOT VCPKG_USE_HEAD_VERSION)
        set(downloaded_file_name "${org_name}-${repo_name}-${sanitized_ref}-${arg_FILE_DISAMBIGUATOR}.tar.gz")
    else()
        set(downloaded_file_name "${org_name}-${repo_name}-${sanitized_ref}.tar.gz")
    endif()


    # exports VCPKG_HEAD_VERSION to the caller. This will get picked up by ports.cmake after the build.
    if(VCPKG_USE_HEAD_VERSION)
        vcpkg_download_distfile(archive_version
            URLS "${github_api_url}/repos/${org_name}/${repo_name}/git/refs/heads/${arg_HEAD_REF}"
            FILENAME "${downloaded_file_name}.version"
            ${headers_param}
            SKIP_SHA512
            ALWAYS_REDOWNLOAD
        )
        # Parse the github refs response with regex.
        # TODO: add json-pointer support to vcpkg
        file(READ "${archive_version}" version_contents)
        if(NOT version_contents MATCHES [["sha":"([a-f0-9]+)"]])
            message(FATAL_ERROR "Failed to parse API response from '${version_url}':

${version_contents}
")
        endif()
        set(VCPKG_HEAD_VERSION "${CMAKE_MATCH_1}" PARENT_SCOPE)
    endif()

    # Try to download the file information from github
    vcpkg_download_distfile(archive
        URLS "${github_host}/${org_name}/${repo_name}/archive/${ref_to_use}.tar.gz"
        FILENAME "${downloaded_file_name}"
        ${headers_param}
        ${sha512_param}
        ${redownload_param}
    )
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${archive}"
        REF "${sanitized_ref}"
        PATCHES ${arg_PATCHES}
        ${working_directory_param}
    )
    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
