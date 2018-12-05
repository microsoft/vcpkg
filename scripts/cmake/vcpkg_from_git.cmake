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
##     SHA512 <abcdef123...>
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
## ### SHA512
## The SHA512 hash that should match the archive form of the commit.
##
## This is most easily determined by first setting it to `0`, then trying to build the port. The error message will contain the full hash, which can be copied back into the portfile.
##
## ### REF
## A stable git commit-ish (ideally a tag or commit) that will not change contents. **This should not be a branch.**
##
## For repositories without official releases, this can be set to the full commit id of the current latest master.
##
## ### PATCHES
## A list of patches to be applied to the extracted sources.
##
## Relative paths are based on the port directory.
##
## ## Notes:
## `OUT_SOURCE_PATH`, `REF`, `SHA512`, and `URL` must be specified.
##
## ## Examples:
##
## * [fdlibm](https://github.com/Microsoft/vcpkg/blob/master/ports/fdlibm/portfile.cmake)

function(vcpkg_from_git)
  set(oneValueArgs OUT_SOURCE_PATH URL REF SHA512)
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

  if(NOT DEFINED _vdud_SHA512)
    message(FATAL_ERROR "vcpkg_from_git requires a SHA512 argument. If you do not know the SHA512, add it as 'SHA512 0' and re-run this command.")
  endif()

  # using .tar.gz instead of .zip because the hash of the latter is affected by timezone.
  string(REPLACE "/" "-" SANITIZED_REF "${_vdud_REF}")
  set(TEMP_ARCHIVE "${DOWNLOADS}/temp/${PORT}-${SANITIZED_REF}.tar.gz")
  set(ARCHIVE "${DOWNLOADS}/${PORT}-${SANITIZED_REF}.tar.gz")
  set(TEMP_SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/${SANITIZED_REF}")

  function(test_hash FILE_PATH FILE_KIND CUSTOM_ERROR_ADVICE)
    file(SHA512 ${FILE_PATH} FILE_HASH)
    if(NOT FILE_HASH STREQUAL _vdud_SHA512)
        message(FATAL_ERROR
            "\nFile does not have expected hash:\n"
            "        File path: [ ${FILE_PATH} ]\n"
            "    Expected hash: [ ${_vdud_SHA512} ]\n"
            "      Actual hash: [ ${FILE_HASH} ]\n"
            "${CUSTOM_ERROR_ADVICE}\n")
    endif()
  endfunction()

  if(NOT EXISTS "${ARCHIVE}")
    if(_VCPKG_NO_DOWNLOADS)
        message(FATAL_ERROR "Downloads are disabled, but '${ARCHIVE}' does not exist.")
    endif()
    message(STATUS "Fetching ${_vdud_URL}...")
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
    file(MAKE_DIRECTORY "${DOWNLOADS}/temp")
    vcpkg_execute_required_process(
      COMMAND ${GIT} archive FETCH_HEAD -o "${TEMP_ARCHIVE}"
      WORKING_DIRECTORY ${DOWNLOADS}/git-tmp
      LOGNAME git-archive
    )
    test_hash("${TEMP_ARCHIVE}" "downloaded repo" "")
    get_filename_component(downloaded_file_dir "${ARCHIVE}" DIRECTORY)
    file(MAKE_DIRECTORY "${downloaded_file_dir}")
    file(RENAME "${TEMP_ARCHIVE}" "${ARCHIVE}")
  else()
    message(STATUS "Using cached ${ARCHIVE}")
    test_hash("${ARCHIVE}" "cached file" "Please delete the file and retry if this file should be downloaded again.")
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
