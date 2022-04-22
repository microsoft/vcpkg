#[===[.md:
# vcpkg_from_gitlab

Download and extract a project from Gitlab instances. Enables support for `install --head`.

## Usage:
```cmake
vcpkg_from_gitlab(
    GITLAB_URL <https://gitlab.com>
    OUT_SOURCE_PATH <SOURCE_PATH>
    REPO <gitlab-org/gitlab-ce>
    [REF <v10.7.3>]
    [SHA512 <45d0d7f8cc350...>]
    [HEAD_REF <master>]
    [PATCHES <patch1.patch> <patch2.patch>...]
    [FILE_DISAMBIGUATOR <N>]
)
```

## Parameters:

### GITLAB_URL
The URL of the Gitlab instance to use.

### OUT_SOURCE_PATH
Specifies the out-variable that will contain the extracted location.

This should be set to `SOURCE_PATH` by convention.

### REPO
The organization or user plus the repository name on the Gitlab instance.

### REF
A stable git commit-ish (ideally a tag) that will not change contents. **This should not be a branch.**

For repositories without official releases, this can be set to the full commit id of the current latest master.

If `REF` is specified, `SHA512` must also be specified.

### SHA512
The SHA512 hash that should match the archive (${GITLAB_URL}/${REPO}/-/archive/${REF}/${REPO_NAME}-${REF}.tar.gz).
The REPO_NAME variable is parsed from the value of REPO.

This is most easily determined by first setting it to `0`, then trying to build the port. The error message will contain the full hash, which can be copied back into the portfile.

### HEAD_REF
The unstable git commit-ish (ideally a branch) to pull for `--head` builds.

For most projects, this should be `master`. The chosen branch should be one that is expected to be always buildable on all supported platforms.

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

### FILE_DISAMBIGUATOR
A token to uniquely identify the resulting filename if the SHA512 changes even though a git ref does not, to avoid stepping on the same file name.

## Notes:
At least one of `REF` and `HEAD_REF` must be specified, however it is preferable for both to be present.

This exports the `VCPKG_HEAD_VERSION` variable during head builds.

## Examples:
* [curl][https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake#L75]
* [folly](https://github.com/Microsoft/vcpkg/blob/master/ports/folly/portfile.cmake#L15)
* [z3](https://github.com/Microsoft/vcpkg/blob/master/ports/z3/portfile.cmake#L13)
#]===]

include(vcpkg_execute_in_download_mode)

function(vcpkg_from_gitlab)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;GITLAB_URL;REPO;REF;SHA512;HEAD_REF;FILE_DISAMBIGUATOR"
        "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_gitlab was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_GITLAB_URL)
        message(FATAL_ERROR "GITLAB_URL must be specified.")
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

    set(headers_param "")
    if(DEFINED arg_AUTHORIZATION_TOKEN)
        set(headers_param "HEADERS" "Authorization: token ${arg_AUTHORIZATION_TOKEN}")
    endif()

    if(NOT DEFINED arg_REF AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "At least one of REF or HEAD_REF must be specified.")
    endif()

    if(arg_REPO MATCHES [[^([^/]*)/([^/]*)$]]) # 2 elements
        set(org_name "${CMAKE_MATCH_1}")
        set(repo_name "${CMAKE_MATCH_2}")
        set(gitlab_link "${arg_GITLAB_URL}/${org_name}/${repo_name}")
    elseif(arg_REPO MATCHES [[^([^/]*)/([^/]*)/([^/]*)$]]) # 3 elements
        set(org_name "${CMAKE_MATCH_1}")
        set(group_name "${CMAKE_MATCH_2}")
        set(repo_name "${CMAKE_MATCH_3}")
        set(gitlab_link "${arg_GITLAB_URL}/${org_name}/${group_name}/${repo_name}")
    else()
        message(FATAL_ERROR "REPO (${arg_REPO}) is not a valid repo name. It must be:
    - an organization name followed by a repository name separated by a single slash, or
    - an organization name, group name, and repository name separated by slashes.")
    endif()

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
        # There are issues with the Gitlab API project paths being URL-escaped, so we use git here to get the head revision
        vcpkg_execute_in_download_mode(COMMAND ${GIT} ls-remote
            "${gitlab_link}.git" "${arg_HEAD_REF}"
            RESULT_VARIABLE git_result
            OUTPUT_VARIABLE git_output
        )
        if(NOT git_result EQUAL 0)
            message(FATAL_ERROR "git ls-remote failed to read ref data of repository: '${gitlab_link}'")
        endif()
        if(NOT git_output MATCHES "^([a-f0-9]*)\t")
            message(FATAL_ERROR "git ls-remote returned unexpected result:
${git_output}
")
        endif()
        # When multiple vcpkg_from_gitlab's are used after each other, only use the version from the first (hopefully the primary one).
        if(NOT DEFINED VCPKG_HEAD_VERSION)
            set(VCPKG_HEAD_VERSION "${CMAKE_MATCH_1}" PARENT_SCOPE)
        endif()
    endif()

    # download the file information from gitlab
    vcpkg_download_distfile(archive
        URLS "${gitlab_link}/-/archive/${ref_to_use}/${repo_name}-${ref_to_use}.tar.gz"
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
