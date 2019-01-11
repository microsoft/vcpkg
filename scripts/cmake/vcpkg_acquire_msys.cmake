## # vcpkg_acquire_msys
##
## Download and prepare an MSYS2 instance.
##
## ## Usage
## ```cmake
## vcpkg_acquire_msys(<MSYS_ROOT_VAR> [PACKAGES <package>...])
## ```
##
## ## Parameters
## ### MSYS_ROOT_VAR
## An out-variable that will be set to the path to MSYS2.
##
## ### PACKAGES
## A list of packages to acquire in msys.
##
## To ensure a package is available: `vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.15)`
##
## ## Notes
## A call to `vcpkg_acquire_msys` will usually be followed by a call to `bash.exe`:
## ```cmake
## vcpkg_acquire_msys(MSYS_ROOT)
## set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
##
## vcpkg_execute_required_process(
##     COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
##     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
##     LOGNAME build-${TARGET_TRIPLET}-rel
## )
## ```
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)
## * [libvpx](https://github.com/Microsoft/vcpkg/blob/master/ports/libvpx/portfile.cmake)

function(vcpkg_acquire_msys PATH_TO_ROOT_OUT)
  set(TOOLPATH ${DOWNLOADS}/tools/msys2)
  cmake_parse_arguments(_am "" "" "PACKAGES" ${ARGN})

  if(NOT CMAKE_HOST_WIN32)
    message(FATAL_ERROR "vcpkg_acquire_msys() can only be used on Windows hosts")
  endif()

  # detect host architecture
  if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
  else()
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
  endif()

  if(_vam_HOST_ARCHITECTURE STREQUAL "AMD64")
    set(TOOLSUBPATH msys64)
    set(URLS
      "http://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-20161025.tar.xz"
      "https://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-base-x86_64-20161025.tar.xz/download"
    )
    set(ARCHIVE "msys2-base-x86_64-20161025.tar.xz")
    set(HASH 6c4c18ec59db80b8269698d074866438a624f1ce735ee5005a01b148b02e8f2e966ae381aa1cb4c50f6226c3b7feb271e36907cf26580df084d695b3c9f5c0eb)
    set(STAMP "initialized-msys2_64.stamp")
  else()
    set(TOOLSUBPATH msys32)
    set(URLS
      "http://repo.msys2.org/distrib/i686/msys2-base-i686-20161025.tar.xz"
      "https://sourceforge.net/projects/msys2/files/Base/i686/msys2-base-i686-20161025.tar.xz/download"
    )
    set(ARCHIVE "msys2-base-i686-20161025.tar.xz")
    set(HASH c9260a38e0c6bf963adeaea098c4e376449c1dd0afe07480741d6583a1ac4c138951ccb0c5388bd148e04255a5c1a23bf5ee2d58dcd6607c14f1eaa5639a7c85)
    set(STAMP "initialized-msys2_32.stamp")
  endif()

  set(PATH_TO_ROOT ${TOOLPATH}/${TOOLSUBPATH})

  if(NOT EXISTS "${TOOLPATH}/${STAMP}")

    message(STATUS "Acquiring MSYS2...")
    vcpkg_download_distfile(ARCHIVE_PATH
        URLS ${URLS}
        FILENAME ${ARCHIVE}
        SHA512 ${HASH}
    )

    file(REMOVE_RECURSE ${TOOLPATH}/${TOOLSUBPATH})
    file(MAKE_DIRECTORY ${TOOLPATH})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
      WORKING_DIRECTORY ${TOOLPATH}
    )
    execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman-key --init;pacman-key --populate"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Syu --noconfirm"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    file(WRITE "${TOOLPATH}/${STAMP}" "0")
    message(STATUS "Acquiring MSYS2... OK")
  endif()

  if(_am_PACKAGES)
    message(STATUS "Acquiring MSYS Packages...")
    string(REPLACE ";" " " _am_PACKAGES "${_am_PACKAGES}")

    set(_ENV_ORIGINAL $ENV{PATH})
    set(ENV{PATH} ${PATH_TO_ROOT}/usr/bin)
    vcpkg_execute_required_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "pacman -Sy --noconfirm --needed ${_am_PACKAGES}"
      WORKING_DIRECTORY ${TOOLPATH}
      LOGNAME msys-pacman-${TARGET_TRIPLET}
    )
    set(ENV{PATH} "${_ENV_ORIGINAL}")

    message(STATUS "Acquiring MSYS Packages... OK")
  endif()

  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
