## # vcpkg_from_git
##
## Download and extract a project from git
##
## ## Usage:
## ```cmake
## vcpkg_from_git(
##     OUT_SOURCE_PATH <SOURCE_PATH>
##     URL <https://android.googlesource.com/platform/external/fdlibm>
##     [REF <59f7335e4d...>]
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
## The full commit id of the current latest master.

## ### PATCHES
## A list of patches to be applied to the extracted sources.
##
## Relative paths are based on the port directory.
##
## ## Notes:
## `REF` and `URL` must be specified.
##
## ## Examples:
##
## * [fdlibm](https://github.com/Microsoft/vcpkg/blob/master/ports/fdlibm/portfile.cmake)

function(vcpkg_from_git)
  set(oneValueArgs OUT_SOURCE_PATH URL REF)
  set(multipleValuesArgs PATCHES)
  cmake_parse_arguments(_vdud "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

  if(NOT DEFINED _vdud_OUT_SOURCE_PATH)
    message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
  endif()

  if(NOT DEFINED _vdud_URL)
    message(FATAL_ERROR "The git url must be specified")
  endif()

  if(NOT DEFINED _vdud_REF)
    message(FATAL_ERROR "The git ref must be specified.")
  endif()

  string(REPLACE "/" "-" SANITIZED_REF "${_vdud_REF}")
  set(ARCHIVE "${DOWNLOADS}/${PORT}-${SANITIZED_REF}.tar.gz")
  set(TEMP_SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/${SANITIZED_REF}")

  if(NOT EXISTS "${ARCHIVE}")
    find_program(GIT NAMES git git.cmd)
    # Note: git init is safe to run multiple times
    vcpkg_execute_required_process(
      COMMAND ${GIT} init git-tmp
      WORKING_DIRECTORY ${DOWNLOADS}
      LOGNAME git-init
    )
    vcpkg_execute_required_process(
      COMMAND ${GIT} fetch ${_vdud_URL} ${_vdud_REF} --depth 1 -n
      WORKING_DIRECTORY ${DOWNLOADS}/git-tmp
      LOGNAME git-fetch
    )
    vcpkg_execute_required_process(
      COMMAND ${GIT} archive ${_vdud_REF} -o "${ARCHIVE}"
      WORKING_DIRECTORY ${DOWNLOADS}/git-tmp
      LOGNAME git-archive
    )
  endif()

  vcpkg_extract_source_archive("${ARCHIVE}" "${TEMP_SOURCE_PATH}")

  vcpkg_apply_patches(
    SOURCE_PATH "${TEMP_SOURCE_PATH}"
    PATCHES ${_vdud_PATCHES}
  )
  set(${_vdud_OUT_SOURCE_PATH} "${TEMP_SOURCE_PATH}" PARENT_SCOPE)
  message(STATUS "Using source at ${TEMP_SOURCE_PATH}")
endfunction()
