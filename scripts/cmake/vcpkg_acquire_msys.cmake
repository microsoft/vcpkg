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
      "https://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-base-x86_64-20190524.tar.xz/download"
      "http://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-20190524.tar.xz"
    )
    set(ARCHIVE "msys2-base-x86_64-20190524.tar.xz")
    set(HASH 50796072d01d30cc4a02df0f9dafb70e2584462e1341ef0eff94e2542d3f5173f20f81e8f743e9641b7528ea1492edff20ce83cb40c6e292904905abe2a91ccc)
    set(STAMP "initialized-msys2_64.stamp")
  else()
    set(TOOLSUBPATH msys32)
    set(URLS
      "https://sourceforge.net/projects/msys2/files/Base/i686/msys2-base-i686-20190524.tar.xz/download"
      "http://repo.msys2.org/distrib/i686/msys2-base-i686-20190524.tar.xz"
    )
    set(ARCHIVE "msys2-base-i686-20190524.tar.xz")
    set(HASH b26d7d432e1eabe2138c4caac5f0a62670f9dab833b9e91ca94b9e13d29a763323b0d30160f09a381ac442b473482dac799be0fea5dd7b28ea2ddd3ba3cd3c25)
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

    # download the new keyring, without it new packages and package updates
    # might not install
    vcpkg_download_distfile(KEYRING_PATH
        URLS http://repo.msys2.org/msys/x86_64/msys2-keyring-r21.b39fb11-1-any.pkg.tar.xz
        FILENAME msys2-keyring-r21.b39fb11-1-any.pkg.tar.xz
        SHA512 a5023fd17ccf6364bc6e27c5e63aea25f1fc264a5247cbae4008864c828c38c3e0b4de09ded650e28d2e24e319b5fcf7a9c0da0fa3a8ac81679470fc6bd120c9
    )
    vcpkg_download_distfile(KEYRING_SIG_PATH
        URLS http://repo.msys2.org/msys/x86_64/msys2-keyring-r21.b39fb11-1-any.pkg.tar.xz.sig
        FILENAME msys2-keyring-r21.b39fb11-1-any.pkg.tar.xz.sig
        SHA512 c326fefd13f58339afe0d0dc78306aa6ab27cafa8c4d792c2d34aa81fdd1f759d490990ab79daa9664a03a6dfa14ffd2b2ad828bf19a883410112d01f5ed6c4c
    )

    file(REMOVE_RECURSE ${TOOLPATH}/${TOOLSUBPATH})
    file(MAKE_DIRECTORY ${TOOLPATH})
    _execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman-key --init;pacman-key --populate"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    # install the new keyring
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman-key --verify ${KEYRING_SIG_PATH}"
      WORKING_DIRECTORY ${TOOLPATH}
      RESULT_VARIABLE _vam_error_code
    )
    if(_vam_error_code)
      message(FATAL_ERROR "Cannot verify MSYS2 keyring.")
    endif()
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -U ${KEYRING_PATH} --noconfirm"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    # we have to kill all GnuPG daemons otherwise bash would potentially not be
    # able to start after the core system upgrade, additionally vcpkg would
    # likely hang waiting for spawned processes to exit
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;gpgconf --homedir /etc/pacman.d/gnupg --kill all"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    # we need to update pacman before anything else due to pacman transitioning
    # to using zstd packages, and our pacman is too old to support those
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Sy pacman --noconfirm"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    # dash relies on specific versions of the base packages, which prevents us
    # from doing a proper update. However, we don't need it so we remove it
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Rc dash --noconfirm"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
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
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "pacman -S --noconfirm --needed ${_am_PACKAGES}"
      WORKING_DIRECTORY ${TOOLPATH}
      LOGNAME msys-pacman-${TARGET_TRIPLET}
    )
    set(ENV{PATH} "${_ENV_ORIGINAL}")

    message(STATUS "Acquiring MSYS Packages... OK")
  endif()

  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
