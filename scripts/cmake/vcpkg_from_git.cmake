#[===[.md:
# vcpkg_from_git

Download and extract a project from git

## Usage:
```cmake
vcpkg_from_git(
    OUT_SOURCE_PATH <SOURCE_PATH>
    URL <https://android.googlesource.com/platform/external/fdlibm>
    REF <59f7335e4d...>
    SHA512 <abc123fed...>
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

### SHA512
The SHA512 hash of the intermediate archive tarball.

This helper uses `git archive` to convert the given commit into a flat
.tar.gz archive; this is the hash of that archive.

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

## Notes:
`OUT_SOURCE_PATH`, `REF`, `SHA512`, and `URL` must be specified.

## Examples:

* [fdlibm](https://github.com/Microsoft/vcpkg/blob/master/ports/fdlibm/portfile.cmake)
#]===]

include(vcpkg_execute_in_download_mode)

function(vcpkg_from_git)
  set(oneValueArgs OUT_SOURCE_PATH URL SHA512 REF)
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

  if(NOT DEFINED _vdud_SHA512)
    message("${_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" "Calling vcpkg_from_git() without a SHA512 argument is deprecated. Please add
    SHA512 0
to the call to determine the correct actual hash.")
  endif()

  # using .tar.gz instead of .zip because the hash of the latter is affected by timezone.
  string(REPLACE "/" "-" SANITIZED_REF "${_vdud_REF}")
  set(TEMP_ARCHIVE "${DOWNLOADS}/temp/${PORT}-${SANITIZED_REF}-git.tar.gz")
  set(ARCHIVE "${DOWNLOADS}/${PORT}-${SANITIZED_REF}-git2.tar.gz")

  function(test_hash FILE_PATH)
    if(_VCPKG_INTERNAL_NO_HASH_CHECK)
      # When using the internal hash skip, do not output an explicit message.
      return()
    endif()

    if(NOT DEFINED _vdud_SHA512)
      return()
    endif()

    file(SHA512 ${FILE_PATH} ACTUAL_HASH)
    if(NOT ACTUAL_HASH STREQUAL _vdud_SHA512)
      message(FATAL_ERROR
          "\nFile does not have expected hash:\n"
          "        File path: [ ${FILE_PATH} ]\n"
          "    Expected hash: [ ${_vdud_SHA512} ]\n"
          "      Actual hash: [ ${ACTUAL_HASH} ]\n")
    endif()
  endfunction()

  if(NOT EXISTS "${ARCHIVE}")
    if(_VCPKG_NO_DOWNLOADS)
        message(FATAL_ERROR "Downloads are disabled, but '${ARCHIVE}' does not exist.")
    endif()
    message(STATUS "Fetching ${_vdud_URL}...")
    file(REMOVE_RECURSE "${DOWNLOADS}/${PORT}-${SANITIZED_REF}")
    find_program(GIT NAMES git git.cmd)
    # Note: git init is safe to run multiple times
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${GIT} init ${PORT}-${SANITIZED_REF}
      WORKING_DIRECTORY ${DOWNLOADS}
      LOGNAME git-init-${TARGET_TRIPLET}
    )
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${GIT} fetch ${_vdud_URL} ${_vdud_REF} --depth 1 -n
      WORKING_DIRECTORY ${DOWNLOADS}/${PORT}-${SANITIZED_REF}
      LOGNAME git-fetch-${TARGET_TRIPLET}
    )
    vcpkg_execute_in_download_mode(
      COMMAND ${GIT} rev-parse FETCH_HEAD
      OUTPUT_VARIABLE REV_PARSE_HEAD
      ERROR_VARIABLE REV_PARSE_HEAD
      RESULT_VARIABLE error_code
      WORKING_DIRECTORY ${DOWNLOADS}/${PORT}-${SANITIZED_REF}
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
      # The gzip command must not match "gzip -cn" in order to prevent Git for Windows from using the built-in compress
      # library. This is necessary because the built-in compress library will embed a "TOS/20" OS target into the
      # produced archive, which won't hash-match with the "Unix" OS target produced on other systems.
      #
      # This behavior was introduced in git-for-windows/git#2077
      COMMAND ${GIT} -c "tar.tar.gz.command=gzip  -cn" archive "${REV_PARSE_HEAD}" -o "${TEMP_ARCHIVE}"
      WORKING_DIRECTORY ${DOWNLOADS}/${PORT}-${SANITIZED_REF}
      LOGNAME git-archive
    )
    test_hash("${TEMP_ARCHIVE}")

    file(REMOVE_RECURSE "${DOWNLOADS}/${PORT}-${SANITIZED_REF}")

    get_filename_component(downloaded_file_dir "${ARCHIVE}" DIRECTORY)
    file(MAKE_DIRECTORY "${downloaded_file_dir}")
    file(RENAME "${TEMP_ARCHIVE}" "${ARCHIVE}")
  else()
    message(STATUS "Using cached ${ARCHIVE}")
    test_hash("${ARCHIVE}")
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
