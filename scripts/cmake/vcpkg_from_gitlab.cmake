## # vcpkg_from_gitlab
##
## Download and extract a project from Gitlab instances. Enables support for `install --head`.
##
## ## Usage:
## ```cmake
## vcpkg_from_gitlab(
##     GITLAB_URL <https://gitlab.com>
##     OUT_SOURCE_PATH <SOURCE_PATH>
##     REPO <gitlab-org/gitlab-ce>
##     [REF <v10.7.3>]
##     [SHA512 <45d0d7f8cc350...>]
##     [HEAD_REF <master>]
##     [PATCHES <patch1.patch> <patch2.patch>...]
## )
## ```
##
## ## Parameters:
##
## ### GITLAB_URL
## The URL of the Gitlab instance to use.
##
## ### OUT_SOURCE_PATH
## Specifies the out-variable that will contain the extracted location.
##
## This should be set to `SOURCE_PATH` by convention.
##
## ### REPO
## The organization or user plus the repository name on the Gitlab instance.
##
## ### REF
## A stable git commit-ish (ideally a tag) that will not change contents. **This should not be a branch.**
##
## For repositories without official releases, this can be set to the full commit id of the current latest master.
##
## If `REF` is specified, `SHA512` must also be specified.
##
## ### SHA512
## The SHA512 hash that should match the archive (${GITLAB_URL}/${REPO}/-/archive/${REF}/${REPO_NAME}-${REF}.tar.gz).
## The REPO_NAME variable is parsed from the value of REPO.
##
## This is most easily determined by first setting it to `1`, then trying to build the port. The error message will contain the full hash, which can be copied back into the portfile.
##
## ### HEAD_REF
## The unstable git commit-ish (ideally a branch) to pull for `--head` builds.
##
## For most projects, this should be `master`. The chosen branch should be one that is expected to be always buildable on all supported platforms.
##
## ### PATCHES
## A list of patches to be applied to the extracted sources.
##
## Relative paths are based on the port directory.
##
## ## Notes:
## At least one of `REF` and `HEAD_REF` must be specified, however it is preferable for both to be present.
##
## This exports the `VCPKG_HEAD_VERSION` variable during head builds.
##
## ## Examples:
## * [curl][https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake#L75]
## * [folly](https://github.com/Microsoft/vcpkg/blob/master/ports/folly/portfile.cmake#L15)
## * [z3](https://github.com/Microsoft/vcpkg/blob/master/ports/z3/portfile.cmake#L13)
##
function(vcpkg_from_gitlab)
    set(oneValueArgs OUT_SOURCE_PATH GITLAB_URL USER REPO REF SHA512 HEAD_REF)
    set(multipleValuesArgs PATCHES)
    cmake_parse_arguments(_vdud "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

    if(NOT DEFINED _vdud_GITLAB_URL)
        message(FATAL_ERROR "GITLAB_URL must be specified.")
    endif()

    if(NOT DEFINED _vdud_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()

    if((DEFINED _vdud_REF AND NOT DEFINED _vdud_SHA512) OR (NOT DEFINED _vdud_REF AND DEFINED _vdud_SHA512))
        message(FATAL_ERROR "SHA512 must be specified if REF is specified.")
    endif()

    if(NOT DEFINED _vdud_REPO)
        message(FATAL_ERROR "REPO must be specified.")
    endif()

    if(NOT DEFINED _vdud_REF AND NOT DEFINED _vdud_HEAD_REF)
        message(FATAL_ERROR "At least one of REF and HEAD_REF must be specified.")
    endif()

    if(VCPKG_USE_HEAD_VERSION AND NOT DEFINED _vdud_HEAD_REF)
        message(STATUS "Package does not specify HEAD_REF. Falling back to non-HEAD version.")
        set(VCPKG_USE_HEAD_VERSION OFF)
    endif()

    string(REGEX REPLACE ".*/" "" REPO_NAME ${_vdud_REPO})
    string(REGEX REPLACE "/.*" "" ORG_NAME ${_vdud_REPO})

    # Handle --no-head scenarios
    if(NOT VCPKG_USE_HEAD_VERSION)
        if(NOT _vdud_REF)
            message(FATAL_ERROR "Package does not specify REF. It must built using --head.")
        endif()

        string(REPLACE "/" "-" SANITIZED_REF "${_vdud_REF}")

        vcpkg_download_distfile(ARCHIVE
            URLS "${_vdud_GITLAB_URL}/${ORG_NAME}/${REPO_NAME}/-/archive/${_vdud_REF}/${REPO_NAME}-${_vdud_REF}.tar.gz"
            SHA512 "${_vdud_SHA512}"
            FILENAME "${ORG_NAME}-${REPO_NAME}-${SANITIZED_REF}.tar.gz"
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
    set(URL "${_vdud_GITLAB_URL}/${ORG_NAME}/${REPO_NAME}/-/archive/${_vdud_HEAD_REF}/${_vdud_HEAD_REF}.tar.gz")
    string(REPLACE "/" "-" SANITIZED_HEAD_REF "${_vdud_HEAD_REF}")
    set(downloaded_file_name "${ORG_NAME}-${REPO_NAME}-${SANITIZED_HEAD_REF}.tar.gz")
    set(downloaded_file_path "${DOWNLOADS}/${downloaded_file_name}")

    if(_VCPKG_NO_DOWNLOADS)
        if(NOT EXISTS ${downloaded_file_path} OR NOT EXISTS ${downloaded_file_path}.version)
            message(FATAL_ERROR "Downloads are disabled, but '${downloaded_file_path}' does not exist.")
        endif()
        message(STATUS "Using cached ${downloaded_file_path}")
    else()
        if(EXISTS ${downloaded_file_path})
            message(STATUS "Purging cached ${downloaded_file_path} to fetch latest (use --no-downloads to suppress)")
            file(REMOVE ${downloaded_file_path})
        endif()
        if(EXISTS ${downloaded_file_path}.version)
            file(REMOVE ${downloaded_file_path}.version)
        endif()
        if(EXISTS ${CURRENT_BUILDTREES_DIR}/src/head)
            file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src/head)
        endif()

        vcpkg_download_distfile(ARCHIVE
            URLS ${URL}
            FILENAME ${downloaded_file_name}
            SKIP_SHA512
        )
    endif()

    # There are issues with the Gitlab API project paths being URL-escaped, so we use git here to get the head revision
    execute_process(COMMAND ${GIT} ls-remote
        "${_vdud_GITLAB_URL}/${ORG_NAME}/${REPO_NAME}.git" "${_vdud_HEAD_REF}"
        RESULT_VARIABLE _git_result
        OUTPUT_VARIABLE _git_output
    )
    string(REGEX MATCH "[a-f0-9]+" _version "${_git_output}")
    # exports VCPKG_HEAD_VERSION to the caller. This will get picked up by ports.cmake after the build.
    # When multiple vcpkg_from_gitlab's are used after each other, only use the version from the first (hopefully the primary one).
    if(NOT DEFINED VCPKG_HEAD_VERSION)
        set(VCPKG_HEAD_VERSION ${_version} PARENT_SCOPE)
    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${downloaded_file_path}"
        REF "${SANITIZED_HEAD_REF}"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src/head
        PATCHES ${_vdud_PATCHES}
    )
    set(${_vdud_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
