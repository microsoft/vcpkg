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

    # workaround for https://github.com/msys2/MSYS2-packages/issues/1962
    # update the package manager manually
    if(_vam_HOST_ARCHITECTURE STREQUAL "AMD64")
      set(ARCHIVE_LIBZSTD "libzstd-1.4.4-2-x86_64.pkg.tar.xz")
      set(HASH_LIBZSTD 7f8d93f8340be8fc2ed9aa60b78bd5b05b954ca6f081d475ccd14dda088c5b1c992a4e7c0c0575877d021edf7f2f55545f21a77212cad244c78866b73f7d2a0c)
      set(ARCHIVE_ZSTD "zstd-1.4.4-2-x86_64.pkg.tar.xz")
      set(HASH_ZSTD 2be7e243d4e600d092aa6a630d24cfc536a6c06a4fa8e0909b0364569d2f938e24f220de1f52edbc36adc7c69ca23a2a730675f2da82c1530d3d91136089d3e2)
      set(ARCHIVE_PACMAN "pacman-5.2.1-6-x86_64.pkg.tar.xz")
      set(HASH_PACMAN d52a1352af7e4cd020fe4083390f48d1c1976a8c8dcb12611de9bbdd7dd07d71f2e32b107d4daef29ff09d8344f545aed239544824225e282f309438178e123e)
      set(URL_ARCH x86_64)
    else()
      set(ARCHIVE_LIBZSTD "libzstd-1.4.4-2-i686.pkg.tar.xz")
      set(HASH_LIBZSTD 5c8c3a259a3ede68a389a782ec6db76e942e90c8ee00b81417e09bb3d604564ce7a28c6d575be786a8cd2e931d2549fe9db7f238a9fbfff159542ec35d42774b)
      set(ARCHIVE_ZSTD "zstd-1.4.4-2-i686.pkg.tar.xz")
      set(HASH_ZSTD c806d78cfd5c9c4c37b82748b98397bb79413f8525fb6c7af35879b947afe3ea4d06e67902b6abe2386052352abe2db2f889f41b42a5c6913d723d0f316dcc41)
      set(ARCHIVE_PACMAN "pacman-5.2.1-6-i686.pkg.tar.xz")
      set(HASH_PACMAN 9f22bc4d2c62f6d823fd2b24ba872d37a6a69a87608f63f9217e8e5f1ce37331e0a795ed6ce7793615f0e240b3ab6359e45259f3a548bd357a27f7f5d0b0a5b4)
      set(URL_ARCH i686)
    endif()
    vcpkg_download_distfile(ARCHIVE_LIBZSTD_PATH
        URLS "https://sourceforge.net/projects/msys2/files/REPOS/MSYS2/${URL_ARCH}/${ARCHIVE_LIBZSTD}/download"
             "http://repo.msys2.org/msys/${URL_ARCH}/${ARCHIVE_LIBZSTD}"
        FILENAME ${ARCHIVE_LIBZSTD}
        SHA512 ${HASH_LIBZSTD}
    )
    vcpkg_download_distfile(ARCHIVE_ZSTD_PATH
        URLS "https://sourceforge.net/projects/msys2/files/REPOS/MSYS2/${URL_ARCH}/${ARCHIVE_ZSTD}/download"
             "http://repo.msys2.org/msys/${URL_ARCH}/${ARCHIVE_ZSTD}"
        FILENAME ${ARCHIVE_ZSTD}
        SHA512 ${HASH_ZSTD}
    )
    vcpkg_download_distfile(ARCHIVE_PACMAN_PATH
        URLS "https://sourceforge.net/projects/msys2/files/REPOS/MSYS2/${URL_ARCH}/${ARCHIVE_PACMAN}/download"
             "http://repo.msys2.org/msys/${URL_ARCH}/${ARCHIVE_PACMAN}"
        FILENAME ${ARCHIVE_PACMAN}
        SHA512 ${HASH_PACMAN}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman --noconfirm -U ${ARCHIVE_LIBZSTD_PATH}"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman --noconfirm -U ${ARCHIVE_ZSTD_PATH}"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman --noconfirm -U ${ARCHIVE_PACMAN_PATH}"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    # we have to kill all GnuPG daemons otherwise they will interfere with the
    # subsequent package installs and updates
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;gpgconf --homedir /etc/pacman.d/gnupg --kill all"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    # end workaround

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
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "pacman -Sy --noconfirm --needed ${_am_PACKAGES}"
      WORKING_DIRECTORY ${TOOLPATH}
      LOGNAME msys-pacman-${TARGET_TRIPLET}
    )
    set(ENV{PATH} "${_ENV_ORIGINAL}")

    message(STATUS "Acquiring MSYS Packages... OK")
  endif()

  # Deal with a stale process created by MSYS
  if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
      vcpkg_execute_required_process(
          ALLOW_IN_DOWNLOAD_MODE
          COMMAND TASKKILL /F /IM gpg-agent.exe /fi "memusage gt 2"
          WORKING_DIRECTORY ${TOOLPATH}
      )
  endif()

  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
