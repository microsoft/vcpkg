## # vcpkg_from_sourceforge
##
## Download and extract a project from sourceforge.
##
## ## Usage:
## ```cmake
## vcpkg_from_sourceforge(
##     OUT_SOURCE_PATH <SOURCE_PATH>
##     REPO <cunit/CUnit>
##     [REF] <2.1-3>
##     SHA512 <547b417109332...>
##     FILENAME <CUnit-2.1-3.tar.bz2>
##     [DISABLE_SSL]
##     [NO_REMOVE_ONE_LEVEL]
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
## The organization or user and repository (optional) on sourceforge.
##
## ### REF
## A stable version number that will not change contents.
##
## For example, we can get the download link:
## https://sourceforge.net/settings/mirror_choices?projectname=mad&filename=libmad/0.15.1b/libmad-0.15.1b.tar.gz&selected=nchc
## So the REPO is `mad/libmad`, and the REF is `0.15.1b`.
##
## For some special links:
## https://sourceforge.net/settings/mirror_choices?projectname=soxr&filename=soxr-0.1.3-Source.tar.xz&selected=nchc
## The REPO is `soxr` and REF is not exist.
##
## ### SHA512
## The SHA512 hash that should match the archive.
##
## ### PATCHES
## A list of patches to be applied to the extracted sources.
##
## Relative paths are based on the port directory.
##
## This field should contain the scheme, host, and port of the desired URL without a trailing slash.
##
## ### DISABLE_SSL
## Disable ssl when downloading source.
##
## ### NO_REMOVE_ONE_LEVEL
## Specifies that the default removal of the top level folder should not occur.
##
## ## Examples:
##
## * [cunit](https://github.com/Microsoft/vcpkg/blob/master/ports/cunit/portfile.cmake)
## * [polyclipping](https://github.com/Microsoft/vcpkg/blob/master/ports/polyclipping/portfile.cmake)
## * [tinyfiledialogs](https://github.com/Microsoft/vcpkg/blob/master/ports/tinyfiledialogs/portfile.cmake)

function(vcpkg_from_sourceforge)
    set(booleanValueArgs DISABLE_SSL NO_REMOVE_ONE_LEVEL)
    set(oneValueArgs OUT_SOURCE_PATH REPO REF SHA512 FILENAME)
    set(multipleValuesArgs PATCHES)
    cmake_parse_arguments(_vdus "${booleanValueArgs}" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

    if(NOT DEFINED _vdus_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()

    if(NOT DEFINED _vdus_SHA512)
        message(FATAL_ERROR "SHA512 must be specified.")
    endif()

    if(NOT DEFINED _vdus_REPO)
        message(FATAL_ERROR "The sourceforge repository must be specified.")
    endif()

    if (_vdus_DISABLE_SSL)
        set(URL_PROTOCOL http:)
    else()
        set(URL_PROTOCOL https:)
    endif()
    set(SOURCEFORGE_HOST ${URL_PROTOCOL}//downloads.sourceforge.net/project)

    string(FIND ${_vdus_REPO} "/" FOUND_ORG)
    if (NOT FOUND_ORG EQUAL -1)
        string(REGEX REPLACE ".*/" "" REPO_NAME ${_vdus_REPO})
        string(REGEX REPLACE "/.*" "" ORG_NAME ${_vdus_REPO})
        set(ORG_NAME ${ORG_NAME}/)
    else()
        set(REPO_NAME ${_vdus_REPO})
        set(ORG_NAME )
    endif()

    if(VCPKG_USE_HEAD_VERSION AND NOT DEFINED _vdus_HEAD_REF)
        message(STATUS "Package does not specify HEAD_REF. Falling back to non-HEAD version.")
        set(VCPKG_USE_HEAD_VERSION OFF)
    endif()
    
    if (DEFINED _vdus_REF)
        set(URL "${SOURCEFORGE_HOST}/${ORG_NAME}${REPO_NAME}/${_vdus_REF}/${_vdus_FILENAME}")
    else()
        set(URL "${SOURCEFORGE_HOST}/${ORG_NAME}${REPO_NAME}/${_vdus_FILENAME}")
    endif()
        
    set(NO_REMOVE_ONE_LEVEL )
    if (_vdus_NO_REMOVE_ONE_LEVEL)
        set(NO_REMOVE_ONE_LEVEL NO_REMOVE_ONE_LEVEL)
    endif()

    # Handle --no-head scenarios
    if(NOT VCPKG_USE_HEAD_VERSION)
        if (DEFINED _vdus_HEAD_REF)
            string(REPLACE "/" "-" SANITIZED_REF "${_vdus_REF}")
        else()
            string(SUBSTRING "${_vdus_SHA512}" 0 10 SANITIZED_REF)
        endif()

        vcpkg_download_distfile(ARCHIVE
            URLS "${URL}"
            SHA512 "${_vdus_SHA512}"
            FILENAME "${_vdus_FILENAME}"
        )

        vcpkg_extract_source_archive_ex(
            OUT_SOURCE_PATH SOURCE_PATH
            ARCHIVE "${ARCHIVE}"
            REF "${SANITIZED_REF}"
            ${NO_REMOVE_ONE_LEVEL}
            PATCHES ${_vdus_PATCHES}
        )

        set(${_vdus_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
        
        return()
    endif()

    # The following is for --head scenarios
    string(REPLACE "/" "-" SANITIZED_HEAD_REF "${_vdus_HEAD_REF}")
    set(downloaded_file_name "${_vdus_FILENAME}")
    set(downloaded_file_path "${DOWNLOADS}/${downloaded_file_name}")

    # exports VCPKG_HEAD_VERSION to the caller. This will get picked up by ports.cmake after the build.
    # When multiple vcpkg_from_sourceforge's are used after each other, only use the version from the first (hopefully the primary one).
    if(NOT DEFINED VCPKG_HEAD_VERSION)
        set(VCPKG_HEAD_VERSION ${REF} PARENT_SCOPE)
    endif()

    vcpkg_extract_source_archive_ex(
        SKIP_PATCH_CHECK
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${downloaded_file_path}"
        REF "${SANITIZED_HEAD_REF}"
        ${NO_REMOVE_ONE_LEVEL}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src/head
        PATCHES ${_vdus_PATCHES}
    )
    set(${_vdus_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
