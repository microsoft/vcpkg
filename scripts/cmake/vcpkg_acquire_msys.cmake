## # vcpkg_acquire_msys
##
## Download and prepare an MSYS2 instance.
##
## ## Usage
## ```cmake
## vcpkg_acquire_msys(<MSYS_ROOT_VAR>)
## ```
##
## ## Parameters
## ### MSYS_ROOT_VAR
## An out-variable that will be set to the path to MSYS2.
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
## To ensure a package is available:
## ```cmake
## vcpkg_acquire_msys(MSYS_ROOT)
## set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
##
## message(STATUS "Installing MSYS Packages")
## vcpkg_execute_required_process(
##     COMMAND
##         ${BASH} --noprofile --norc -c
##             'PATH=/usr/bin:\$PATH pacman -Sy --noconfirm --needed make'
##     WORKING_DIRECTORY ${MSYS_ROOT}
##     LOGNAME pacman-${TARGET_TRIPLET})
## ```
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)
## * [libvpx](https://github.com/Microsoft/vcpkg/blob/master/ports/libvpx/portfile.cmake)

function(vcpkg_acquire_msys PATH_TO_ROOT_OUT)
  set(TOOLPATH ${DOWNLOADS}/tools/msys2)

  # detect host architecture
  if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
  else()
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
  endif()

  if(_vam_HOST_ARCHITECTURE STREQUAL "AMD64")
    set(TOOLSUBPATH msys64)
    set(URL "https://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-base-x86_64-20161025.tar.xz/download")
    set(ARCHIVE "msys2-base-x86_64-20161025.tar.xz")
    set(HASH 6c4c18ec59db80b8269698d074866438a624f1ce735ee5005a01b148b02e8f2e966ae381aa1cb4c50f6226c3b7feb271e36907cf26580df084d695b3c9f5c0eb)
    set(STAMP "initialized-msys2.stamp")
  else()
    set(TOOLSUBPATH msys32)
    set(URL "https://sourceforge.net/projects/msys2/files/Base/i686/msys2-base-i686-20161025.tar.xz/download")
    set(ARCHIVE "msys2-base-i686-20161025.tar.xz")
    set(HASH c9260a38e0c6bf963adeaea098c4e376449c1dd0afe07480741d6583a1ac4c138951ccb0c5388bd148e04255a5c1a23bf5ee2d58dcd6607c14f1eaa5639a7c85)
    set(STAMP "initialized-msys2_x64.stamp")
  endif()

  set(PATH_TO_ROOT ${TOOLPATH}/${TOOLSUBPATH})

  if(NOT EXISTS "${TOOLPATH}/${STAMP}")
    message(STATUS "Acquiring MSYS2...")
    file(DOWNLOAD ${URL} ${DOWNLOADS}/${ARCHIVE}
      EXPECTED_HASH SHA512=${HASH}
    )
    file(REMOVE_RECURSE ${TOOLPATH}/${TOOLSUBPATH})
    file(MAKE_DIRECTORY ${TOOLPATH})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${DOWNLOADS}/${ARCHIVE}
      WORKING_DIRECTORY ${TOOLPATH}
    )
    execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin:\$PATH;pacman-key --init;pacman-key --populate"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin:\$PATH;pacman -Syu --noconfirm"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    file(WRITE "${TOOLPATH}/${STAMP}" "0")
    message(STATUS "Acquiring MSYS2... OK")
  endif()

  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
