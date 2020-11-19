## # vcpkg_from_git
##
## Download and extract a project from git
##
## ## Usage:
## ```cmake
## vcpkg_from_git(
##     OUT_SOURCE_PATH <SOURCE_PATH>
##     URL <https://android.googlesource.com/platform/external/fdlibm>
##     REF <59f7335e4d...>
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
## ### URL
## The url of the git repository.
##
## ### REF
## The git sha of the commit to download.
##
## ### PATCHES
## A list of patches to be applied to the extracted sources.
##
## Relative paths are based on the port directory.
##
## ## Notes:
## `OUT_SOURCE_PATH`, `REF`, and `URL` must be specified.
##
## ## Examples:
##
## * [fdlibm](https://github.com/Microsoft/vcpkg/blob/master/ports/fdlibm/portfile.cmake)

include(vcpkg_execute_in_download_mode)

function(vcpkg_from_git)
  set(oneValueArgs OUT_SOURCE_PATH URL REF)
  set(multipleValuesArgs PATCHES)
  # parse parameters such that semicolons in options arguments to COMMAND don't get erased
  cmake_parse_arguments(PARSE_ARGV 0 _vdud "" "${oneValueArgs}" "${multipleValuesArgs}")

  if(NOT DEFINED _vdud_OUT_SOURCE_PATH)
    message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
  endif()

  if(NOT DEFINED _vdud_URL)
    message(FATAL_ERROR "The git url must be specified")
  endif()

  if(NOT DEFINED _vdud_REF)
    message(FATAL_ERROR "The git ref must be specified.")
  endif()

  # using .tar.gz instead of .zip because the hash of the latter is affected by timezone.
  string(REPLACE "/" "-" SANITIZED_REF "${_vdud_REF}")
  set(TEMP_ARCHIVE "${DOWNLOADS}/temp/${PORT}-${SANITIZED_REF}.tar.gz")
  set(ARCHIVE "${DOWNLOADS}/${PORT}-${SANITIZED_REF}.tar.gz")
  set(TEMP_SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/${SANITIZED_REF}")

  if(NOT EXISTS "${ARCHIVE}")
    if(_VCPKG_NO_DOWNLOADS)
        message(FATAL_ERROR "Downloads are disabled, but '${ARCHIVE}' does not exist.")
    endif()
    message(STATUS "Fetching ${_vdud_URL}...")
    find_program(GIT NAMES git git.cmd)
    # Note: git init is safe to run multiple times
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${GIT} init git-tmp
      WORKING_DIRECTORY ${DOWNLOADS}
      LOGNAME git-init-${TARGET_TRIPLET}
    )
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${GIT} fetch ${_vdud_URL} ${_vdud_REF} --depth 1 -n
      WORKING_DIRECTORY ${DOWNLOADS}/git-tmp
      LOGNAME git-fetch-${TARGET_TRIPLET}
    )
    vcpkg_execute_in_download_mode(
      COMMAND ${GIT} rev-parse FETCH_HEAD
      OUTPUT_VARIABLE REV_PARSE_HEAD
      ERROR_VARIABLE REV_PARSE_HEAD
      RESULT_VARIABLE error_code
      WORKING_DIRECTORY ${DOWNLOADS}/git-tmp
    )
    if(error_code)
        message(FATAL_ERROR "unable to determine FETCH_HEAD after fetching git repository")
    endif()
    string(REGEX REPLACE "\n$" "" REV_PARSE_HEAD "${REV_PARSE_HEAD}")
    if(NOT REV_PARSE_HEAD STREQUAL _vdud_REF)
        message(FATAL_ERROR "REF (${_vdud_REF}) does not match FETCH_HEAD (${REV_PARSE_HEAD})")
    endif()

    file(MAKE_DIRECTORY "${DOWNLOADS}/temp")
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${GIT} archive FETCH_HEAD -o "${TEMP_ARCHIVE}"
      WORKING_DIRECTORY ${DOWNLOADS}/git-tmp
      LOGNAME git-archive
    )

    get_filename_component(downloaded_file_dir "${ARCHIVE}" DIRECTORY)
    file(MAKE_DIRECTORY "${downloaded_file_dir}")
    file(RENAME "${TEMP_ARCHIVE}" "${ARCHIVE}")
  else()
    message(STATUS "Using cached ${ARCHIVE}")
  endif()

  vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF "${SANITIZED_REF}"
    PATCHES ${_vdud_PATCHES}
    NO_REMOVE_ONE_LEVEL
  )

  set(${_vdud_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
