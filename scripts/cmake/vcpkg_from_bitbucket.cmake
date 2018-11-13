## # vcpkg_from_bitbucket
##
## Download and extract a project from Bitbucket.
## Enables support for installing HEAD `vcpkg.exe install --head <port>`.
##
## ## Usage:
## ```cmake
## vcpkg_from_bitbucket(
##     OUT_SOURCE_PATH <SOURCE_PATH>
##     REPO <Microsoft/cpprestsdk>
##     [REF <v2.0.0>]
##     [SHA512 <45d0d7f8cc350...>]
##     [HEAD_REF <master>]
##     [PATCHES <patch1.patch> <patch2.patch>...]
## )
## ```
##
## ## Parameters:
## ### OUT_SOURCE_PATH
## Specifies the out-variable that will contain the extracted location.
##
## This should be set to `SOURCE_PATH` by convention.
##
## ### REPO
## The organization or user and repository on GitHub.
##
## ### REF
## A stable git commit-ish (ideally a tag) that will not change contents. **This should not be a branch.**
##
## For repositories without official releases, this can be set to the full commit id of the current latest master.
##
## If `REF` is specified, `SHA512` must also be specified.
##
## ### SHA512
## The SHA512 hash that should match the archive (https://bitbucket.com/${REPO}/get/${REF}.tar.gz).
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
##
## * [blaze](https://github.com/Microsoft/vcpkg/blob/master/ports/blaze/portfile.cmake)
function(vcpkg_from_bitbucket)
    set(oneValueArgs OUT_SOURCE_PATH REPO REF SHA512 HEAD_REF)
    set(multipleValuesArgs PATCHES)
    cmake_parse_arguments(_vdud "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

    if(NOT _vdud_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()

    if((_vdud_REF AND NOT _vdud_SHA512) OR (NOT _vdud_REF AND _vdud_SHA512))
        message(FATAL_ERROR "SHA512 must be specified if REF is specified.")
    endif()

    if(NOT _vdud_REPO)
        message(FATAL_ERROR "The Bitbucket repository must be specified.")
    endif()

    if(NOT _vdud_REF AND NOT _vdud_HEAD_REF)
        message(FATAL_ERROR "At least one of REF and HEAD_REF must be specified.")
    endif()

    string(REGEX REPLACE ".*/" "" REPO_NAME ${_vdud_REPO})
    string(REGEX REPLACE "/.*" "" ORG_NAME ${_vdud_REPO})

    macro(set_SOURCE_PATH BASE BASEREF)
        set(SOURCE_PATH "${BASE}/${ORG_NAME}-${REPO_NAME}-${BASEREF}")
        if(EXISTS ${SOURCE_PATH})
            set(${_vdud_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
        else()
            # Sometimes GitHub strips a leading 'v' off the REF.
            string(REGEX REPLACE "^v" "" REF ${BASEREF})
            set(SOURCE_PATH "${BASE}/${ORG_NAME}-${REPO_NAME}-${REF}")
            if(EXISTS ${SOURCE_PATH})
                set(${_vdud_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
            else()
                message(FATAL_ERROR "Could not determine source path: '${BASE}/${ORG_NAME}-${REPO_NAME}-${BASEREF}' does not exist")
            endif()
        endif()
    endmacro()

    if(VCPKG_USE_HEAD_VERSION AND NOT _vdud_HEAD_REF)
        message(STATUS "Package does not specify HEAD_REF. Falling back to non-HEAD version.")
        set(VCPKG_USE_HEAD_VERSION OFF)
    endif()

    # Handle --no-head scenarios
    if(NOT VCPKG_USE_HEAD_VERSION)
        if(NOT _vdud_REF)
            message(FATAL_ERROR "Package does not specify REF. It must built using --head.")
        endif()

        set(URL "https://bitbucket.com/${ORG_NAME}/${REPO_NAME}/get/${_vdud_REF}.tar.gz")
        set(downloaded_file_path "${DOWNLOADS}/${ORG_NAME}-${REPO_NAME}-${_vdud_REF}.tar.gz")

        file(DOWNLOAD "https://api.bitbucket.com/2.0/repositories/${ORG_NAME}/${REPO_NAME}/refs/tags/${_vdud_REF}"
            ${downloaded_file_path}.version
            STATUS download_status
        )
        list(GET download_status 0 status_code)
        if ("${status_code}" STREQUAL "0")
            # Parse the github refs response with regex.
            # TODO: use some JSON swiss-army-knife utility instead.
            file(READ "${downloaded_file_path}.version" _contents)
            string(REGEX MATCH "\"hash\": \"[a-f0-9]+\"" x "${_contents}")
            string(REGEX REPLACE "\"hash\": \"([a-f0-9]+)\"" "\\1" _version ${x})
            string(SUBSTRING ${_version} 0 12 _version) # Get the 12 first numbers from commit hash
        else()
            string(SUBSTRING ${_vdud_REF} 0 12 _version) # Get the 12 first numbers from commit hash
        endif()

        vcpkg_download_distfile(ARCHIVE
            URLS "https://bitbucket.com/${ORG_NAME}/${REPO_NAME}/get/${_vdud_REF}.tar.gz"
            SHA512 "${_vdud_SHA512}"
            FILENAME "${ORG_NAME}-${REPO_NAME}-${_vdud_REF}.tar.gz"
        )

        vcpkg_extract_source_archive_ex(
            OUT_SOURCE_PATH SOURCE_PATH
            ARCHIVE "${ARCHIVE}"
            REF "${_vdud_REF}"
            PATCHES ${_vdud_PATCHES}
        )
        set(${_vdud_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
        return()
    endif()

    # The following is for --head scenarios
    set(URL "https://bitbucket.com/${ORG_NAME}/${REPO_NAME}/get/${_vdud_HEAD_REF}.tar.gz")
    set(downloaded_file_name "${ORG_NAME}-${REPO_NAME}-${_vdud_HEAD_REF}.tar.gz")
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

        # Try to download the file and version information from bitbucket.
        vcpkg_download_distfile(ARCHIVE_VERSION
            URLS "https://api.bitbucket.com/2.0/repositories/${ORG_NAME}/${REPO_NAME}/refs/branches/${_vdud_HEAD_REF}"
            FILENAME "${downloaded_file_name}.version"
            SKIP_SHA512
        )

        vcpkg_download_distfile(ARCHIVE
            URLS "${URL}"
            FILENAME "${downloaded_file_name}"
            SKIP_SHA512
        )
    endif()

    # Parse the github refs response with regex.
    # TODO: use some JSON swiss-army-knife utility instead.
    file(READ "${ARCHIVE_VERSION}" _contents)
    string(REGEX MATCH "\"hash\": \"[a-f0-9]+\"" x "${_contents}")
    string(REGEX REPLACE "\"hash\": \"([a-f0-9]+)\"" "\\1" _version ${x})
    string(SUBSTRING ${_version} 0 12 _vdud_HEAD_REF) # Get the 12 first numbers from commit hash

    # exports VCPKG_HEAD_VERSION to the caller. This will get picked up by ports.cmake after the build.
    set(VCPKG_HEAD_VERSION ${_version} PARENT_SCOPE)

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${downloaded_file_path}"
        REF "${_vdud_HEAD_REF}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/head"
        PATCHES ${_vdud_PATCHES}
    )
    set(${_vdud_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
