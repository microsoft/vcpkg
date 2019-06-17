## # vcpkg_find_acquire_program
##
## Download or find a well-known tool.
##
## ## Usage
## ```cmake
## vcpkg_find_acquire_program(
##   <VAR>
##   [REQUIRED_LIBRARY_PATH_VAR <out_var>]
##   [REQUIRED_BINARY_PATH_VAR <out_var>]
##   [VERSION_VAR <out_var>]
## )
## ```
## ## Parameters
## ### VAR
## This variable specifies both the program to be acquired as well as the out parameter that will be set to the path of the program executable.
## ### REQUIRED_LIBRARY_PATH_VAR
## This variable specifies the name of a variable in the parent scope to set with the path to libraries required to run the acquired program. The variable will be set to a list. 
## ### REQUIRED_BINARY_PATH_VAR
## This variable specifies the name of a variable in the parent scope to set with the paths to binaries required to run the acquired program. The variable will be set to a list.
## ### VERSION_VAR
## This variable specifies the name of a variable in the parent scope to set with the version of the program acquired, if applicable.
##
## ## Notes
## The current list of programs includes:
##
## - 7Z
## - BISON
## - FLANG
## - FLEX
## - GASPREPROCESSOR
## - PERL
## - PYTHON2
## - PYTHON3
## - JOM
## - MESON
## - NASM
## - NINJA
## - NUGET
## - YASM
## - ARIA2 (Downloader)
##
## Note that msys2 has a dedicated helper function: [`vcpkg_acquire_msys`](vcpkg_acquire_msys.md).
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
## * [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)
function(vcpkg_find_acquire_program VAR)
  set(EXPANDED_VAR ${${VAR}})
  if(EXPANDED_VAR)
    return()
  endif()

  cmake_parse_arguments(
    _vfa
    ""
    "REQUIRED_LIBRARY_PATH_VAR;REQUIRED_BINARY_PATH_VAR;VERSION_VAR"
    ""
    ${ARGN}
  )

  unset(NOEXTRACT)
  unset(_vfa_RENAME)
  unset(SUBDIR)
  unset(REQUIRED_INTERPRETER)

  vcpkg_get_program_files_platform_bitness(PROGRAM_FILES_PLATFORM_BITNESS)
  vcpkg_get_program_files_32_bit(PROGRAM_FILES_32_BIT)

  if(VAR MATCHES "PERL")
    set(PROGNAME perl)
    set(PATHS ${DOWNLOADS}/tools/perl/perl/bin)
    set(BREW_PACKAGE_NAME "perl")
    set(APT_PACKAGE_NAME "perl")
    set(URL "http://strawberryperl.com/download/5.24.1.1/strawberry-perl-5.24.1.1-32bit-portable.zip")
    set(ARCHIVE "strawberry-perl-5.24.1.1-32bit-portable.zip")
    set(HASH a6e685ea24376f50db5f06c5b46075f1d3be25168fa1f27fa9b02e2ac017826cee62a2b43562f9b6c989337a231ba914416c110075457764de2d11f99d5e0f26)
  elseif(VAR MATCHES "NASM")
    set(PROGNAME nasm)
    set(PATHS ${DOWNLOADS}/tools/nasm/nasm-2.14)
    set(BREW_PACKAGE_NAME "nasm")
    set(APT_PACKAGE_NAME "nasm")
    set(URL "http://www.nasm.us/pub/nasm/releasebuilds/2.14/win32/nasm-2.14-win32.zip")
    set(ARCHIVE "nasm-2.14-win32.zip")
    set(HASH 64481b0346b83de8c9568f04a54f68e0f4c71724afa0b414f12e4080951d8c49e489bfc32117f9a489e3e49477b1cadc583c672311316d27c543af304c4b7f2a)
  elseif(VAR MATCHES "YASM")
    set(PROGNAME yasm)
    set(SUBDIR 1.3.0.6)
    set(PATHS ${DOWNLOADS}/tools/yasm/${SUBDIR})
    set(URL "https://www.tortall.net/projects/yasm/snapshots/v1.3.0.6.g1962/yasm-1.3.0.6.g1962.exe")
    set(ARCHIVE "yasm-1.3.0.6.g1962.exe")
    set(_vfa_RENAME "yasm.exe")
    set(NOEXTRACT ON)
    set(HASH c1945669d983b632a10c5ff31e86d6ecbff143c3d8b2c433c0d3d18f84356d2b351f71ac05fd44e5403651b00c31db0d14615d7f9a6ecce5750438d37105c55b)
  elseif(VAR MATCHES "PYTHON3")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME python)
      set(SUBDIR "python3")
      set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
      set(URL "https://www.python.org/ftp/python/3.5.4/python-3.5.4-embed-win32.zip")
      set(ARCHIVE "python-3.5.4-embed-win32.zip")
      set(HASH b5240fdc95088c2d7f65d2dd598650f8dd106b49589d94156bd4a078b108c6cabbe7a38ef73e2b2cf00e8312a93d2e587eac2c54ce85540d3c7a26cc60013156)
    else()
      set(PROGNAME python3)
      set(BREW_PACKAGE_NAME "python")
      set(APT_PACKAGE_NAME "python3")
    endif()
  elseif(VAR MATCHES "PYTHON2")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME python)
      set(SUBDIR "python2")
      set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
      set(URL "https://www.python.org/ftp/python/2.7.14/python-2.7.14.msi")
      set(ARCHIVE "python2.msi")
      set(HASH 8c3ad6e527742d99ba96dcfd1098861b14e7207b80d51a54e9b410ab2f36e44e05561ea1527d8e92b3e10808311536260bd9e82db0da3b513fb1be18e108510e)
    else()
      set(PROGNAME python2)
      set(BREW_PACKAGE_NAME "python2")
      set(APT_PACKAGE_NAME "python")
    endif()
  elseif(VAR MATCHES "RUBY")
    set(PROGNAME "ruby")
    set(PATHS ${DOWNLOADS}/tools/ruby/rubyinstaller-2.4.1-1-x86/bin)
    set(URL https://github.com/oneclick/rubyinstaller2/releases/download/2.4.1-1/rubyinstaller-2.4.1-1-x86.7z)
    set(ARCHIVE rubyinstaller-2.4.1-1-x86.7z)
    set(HASH b51112e9b58cfcbe8cec0607e8a16fff6a943d9b4e31b2a7fbf5df5f83f050bf0a4812d3dd6000ff21a3d5fd219cd0a309c58ac1c1db950a9b0072405e4b70f5)
  elseif(VAR MATCHES "JOM")
    set(PROGNAME jom)
    set(SUBDIR "jom-1.1.3")
    set(PATHS ${DOWNLOADS}/tools/jom/${SUBDIR})
    set(URL "http://download.qt.io/official_releases/jom/jom_1_1_3.zip")
    set(ARCHIVE "jom_1_1_3.zip")
    set(HASH 5b158ead86be4eb3a6780928d9163f8562372f30bde051d8c281d81027b766119a6e9241166b91de0aa6146836cea77e5121290e62e31b7a959407840fc57b33)
  elseif(VAR MATCHES "7Z")
    set(PROGNAME 7z)
    set(PATHS "${PROGRAM_FILES_PLATFORM_BITNESS}/7-Zip" "${PROGRAM_FILES_32_BIT}/7-Zip" "${DOWNLOADS}/tools/7z/Files/7-Zip")
    set(URL "http://7-zip.org/a/7z1604.msi")
    set(ARCHIVE "7z1604.msi")
    set(HASH 556f95f7566fe23704d136239e4cf5e2a26f939ab43b44145c91b70d031a088d553e5c21301f1242a2295dcde3143b356211f0108c68e65eef8572407618326d)
  elseif(VAR MATCHES "NINJA")
    set(PROGNAME ninja)
    set(SUBDIR "kitware")
    set(FIND_OPTIONS NO_DEFAULT_PATH)
    set(BREW_PACKAGE_NAME "ninja")
    set(APT_PACKAGE_NAME "ninja-build")
    set(SKIP_PACKAGE_MANAGER 1)
    if(CMAKE_HOST_WIN32)
      set(SUBDIR2 "ninja-1.9.0.g99df1.kitware.dyndep-1.jobserver-1_i686-pc-windows-msvc")
      set(URL "https://github.com/Kitware/ninja/releases/download/v1.9.0.g99df1.kitware.dyndep-1.jobserver-1/ninja-1.9.0.g99df1.kitware.dyndep-1.jobserver-1_i686-pc-windows-msvc.zip")
      set(ARCHIVE "ninja-kitware-1.9.0-win.zip")
      set(HASH c3b2953f6320beb7ba792b7285440476384bff0e53fcac37a15c4d4cce4084cdd77eea50912c14ac5a3ba5ed1d89c3421f73515b3f0b7aac1456b4be87670306)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(SUBDIR2 "ninja-1.9.0.g99df1.kitware.dyndep-1.jobserver-1_x86_64-apple-darwin")
      set(URL "https://github.com/Kitware/ninja/releases/download/v1.9.0.g99df1.kitware.dyndep-1.jobserver-1/ninja-1.9.0.g99df1.kitware.dyndep-1.jobserver-1_x86_64-apple-darwin.tar.gz")
      set(ARCHIVE "ninja-kitware-1.9.0-osx.tar.gz")
      set(HASH c97a8967f3aad5ee27d90ed47b2e967939a5453b564a22886fd8316f5fc26e8f4c0069d78ae5404d2d228ab6cd73a2380f17e7c7d1ae0b06c061c306db9af0c1)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      set(SUBDIR2 "ninja-1.9.0.g99df1.kitware.dyndep-1.jobserver-1_x86_64-linux-gnu")
      set(URL "https://github.com/Kitware/ninja/releases/download/v1.9.0.g99df1.kitware.dyndep-1.jobserver-1/ninja-1.9.0.g99df1.kitware.dyndep-1.jobserver-1_x86_64-linux-gnu.tar.gz")
      set(ARCHIVE "ninja-kitware-1.9.0-linux.tar.gz")
      set(HASH  29fbc94a0f6e3cdf8fd930dff20da2ad33c2f7af49f37c946fd2b1f4b3cb9f1b46f82e943a578b68e050ada079b5a220fecf0c8f8d5380f3bd8efab816b8e6cd)
    else()
      unset(FIND_OPTIONS)
      unset(SKIP_PACKAGE_MANAGER)
    endif()
    set(PATHS "${DOWNLOADS}/tools/ninja/${SUBDIR}/${SUBDIR2}")
  elseif(VAR MATCHES "NUGET")
    set(PROGNAME nuget)
    set(PATHS "${DOWNLOADS}/tools/nuget")
    set(BREW_PACKAGE_NAME "nuget")
    set(URL "https://dist.nuget.org/win-x86-commandline/v4.8.1/nuget.exe")
    set(ARCHIVE "nuget.exe")
    set(NOEXTRACT ON)
    set(HASH 42cb744338af8decc033a75bce5b4c4df28e102bafc45f9a8ba86d7bc010f5b43ebacae80d7b28c4f85ac900eefc2a349620ae65f27f6ca1c21c53b63b92924b)
  elseif(VAR MATCHES "MESON")
    set(PROGNAME meson)
    set(REQUIRED_INTERPRETER PYTHON3)
    set(BREW_PACKAGE_NAME "meson")
    set(APT_PACKAGE_NAME "meson")
    if(CMAKE_HOST_WIN32)
      set(SCRIPTNAME meson.py)
    else()
      set(SCRIPTNAME meson)
    endif()
    set(PATHS ${DOWNLOADS}/tools/meson/meson-0.50.0)
    set(URL "https://github.com/mesonbuild/meson/archive/0.50.0.zip")
    set(ARCHIVE "meson-0.50.0.zip")
    set(HASH 587cafe0cd551e3fb3507ecab904912dc3e053aa95c864b435526a20d52406536ba970a50be6c9f20d83314c5853aaefa102c5ca14623d0928b091a43e7b6d64)
  elseif(VAR MATCHES "FLEX")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME win_flex)
      set(SUBDIR win_flex-2.5.16)
      set(PATHS ${DOWNLOADS}/tools/win_flex/${SUBDIR})
      set(URL "https://sourceforge.net/projects/winflexbison/files/winflexbison-2.5.16.zip/download")
      set(ARCHIVE "win_flex_bison-2.5.16.zip")
      set(HASH 0a14154bff5d998feb23903c46961528f8ccb4464375d5384db8c4a7d230c0c599da9b68e7a32f3217a0a0735742242eaf3769cb4f03e00931af8640250e9123)
      if(NOT EXISTS "${PATHS}/data/m4sugar/m4sugar.m4")
        file(REMOVE_RECURSE "${PATHS}")
      endif()
    else()
      set(PROGNAME flex)
      set(APT_PACKAGE_NAME flex)
      set(BREW_PACKAGE_NAME flex)
    endif()
  elseif(VAR MATCHES "BISON")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME win_bison)
      set(SUBDIR win_bison-2.5.16)
      set(PATHS ${DOWNLOADS}/tools/win_bison/${SUBDIR})
      set(URL "https://sourceforge.net/projects/winflexbison/files/winflexbison-2.5.16.zip/download")
      set(ARCHIVE "win_flex_bison-2.5.16.zip")
      set(HASH 0a14154bff5d998feb23903c46961528f8ccb4464375d5384db8c4a7d230c0c599da9b68e7a32f3217a0a0735742242eaf3769cb4f03e00931af8640250e9123)
      if(NOT EXISTS "${PATHS}/data/m4sugar/m4sugar.m4")
        file(REMOVE_RECURSE "${PATHS}")
      endif()
    else()
      set(PROGNAME bison)
      set(APT_PACKAGE_NAME bison)
      set(BREW_PACKAGE_NAME bison)
    endif()
  elseif(VAR MATCHES "GPERF")
    set(PROGNAME gperf)
    set(PATHS ${DOWNLOADS}/tools/gperf/bin)
    set(URL "https://sourceforge.net/projects/gnuwin32/files/gperf/3.0.1/gperf-3.0.1-bin.zip/download")
    set(ARCHIVE "gperf-3.0.1-bin.zip")
    set(HASH 3f2d3418304390ecd729b85f65240a9e4d204b218345f82ea466ca3d7467789f43d0d2129fcffc18eaad3513f49963e79775b10cc223979540fa2e502fe7d4d9)
  elseif(VAR MATCHES "GASPREPROCESSOR")
    set(NOEXTRACT true)
    set(PROGNAME gas-preprocessor)
    set(REQUIRED_INTERPRETER PERL)
    set(SCRIPTNAME "gas-preprocessor.pl")
    set(PATHS ${DOWNLOADS}/tools/gas-preprocessor)
    set(URL "https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/cbe88474ec196370161032a3863ec65050f70ba4/gas-preprocessor.pl")
    set(ARCHIVE "gas-preprocessor.pl")
    set(HASH f6965875608bf2a3ee337e00c3f16e06cd9b5d10013da600d2a70887e47a7b4668af87b3524acf73dd122475712af831495a613a2128c1adb5fe0b4a11d96cd3)
  elseif(VAR MATCHES "DARK")
    set(PROGNAME dark)
    set(SUBDIR "wix311-binaries")
    set(PATHS ${DOWNLOADS}/tools/dark/${SUBDIR})
    set(URL "https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311-binaries.zip")
    set(ARCHIVE "wix311-binaries.zip")
    set(HASH 74f0fa29b5991ca655e34a9d1000d47d4272e071113fada86727ee943d913177ae96dc3d435eaf494d2158f37560cd4c2c5274176946ebdb17bf2354ced1c516)
  elseif(VAR MATCHES "SCONS")
    set(PROGNAME scons)
    set(REQUIRED_INTERPRETER PYTHON2)
    set(SCRIPTNAME "scons.py")
    set(PATHS ${DOWNLOADS}/tools/scons)
    set(URL "https://sourceforge.net/projects/scons/files/scons-local-3.0.1.zip/download")
    set(ARCHIVE "scons-local-3.0.1.zip")
    set(HASH fe121b67b979a4e9580c7f62cfdbe0c243eba62a05b560d6d513ac7f35816d439b26d92fc2d7b7d7241c9ce2a49ea7949455a17587ef53c04a5f5125ac635727)
  elseif(VAR MATCHES "DOXYGEN")
    set(PROGNAME doxygen)
    set(PATHS ${DOWNLOADS}/tools/doxygen)
    set(URL "http://doxygen.nl/files/doxygen-1.8.15.windows.bin.zip")
    set(ARCHIVE "doxygen-1.8.15.windows.bin.zip")
    set(HASH 89482dcb1863d381d47812c985593e736d703931d49994e09c7c03ef67e064115d0222b8de1563a7930404c9bc2d3be323f3d13a01ef18861be584db3d5a953c)
  # Download Tools
  elseif(VAR MATCHES "ARIA2")
    set(PROGNAME aria2c)
    set(PATHS ${DOWNLOADS}/tools/aria2c/aria2-1.33.1-win-32bit-build1)
    set(URL "https://github.com/aria2/aria2/releases/download/release-1.33.1/aria2-1.33.1-win-32bit-build1.zip")
    set(ARCHIVE "aria2-1.33.1-win-32bit-build1.zip")
    set(HASH 2456176ba3d506a07cf0cc4f61f080e1ff8cb4106426d66f354c5bb67a9a8720b5ddb26904275e61b1f623c932355f7dcde4cd17556cc895f11293c23c3a9bf3)
  elseif(VAR MATCHES "FLANG")
    set(ERROR_LIST "")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      if(CMAKE_HOST_WIN32)
        set(VERSION "5.0.0")
        set(CLANG_URL "https://conda.anaconda.org/conda-forge/win-64/clangdev-${FLANG_VERSION}-flang_3.tar.bz2")
        set(LIBFLANG_URL "https://conda.anaconda.org/conda-forge/win-64/libflang-${FLANG_VERSION}-vc14_20180208.tar.bz2")
        set(OPENMP_URL "https://conda.anaconda.org/conda-forge/win-64/openmp-${FLANG_VERSION}-vc14_1.tar.bz2")
        set(FLANG_URL "https://conda.anaconda.org/conda-forge/win-64/flang-${FLANG_VERSION}-vc14_20180208.tar.bz2")

        set(URL_VARS CLANG_URL LIBFLANG_URL OPENMP_URL FLANG_URL)

        set(ARCHIVES
            "clangdev-${VERSION}-flang_3.tar.bz2"
            "libflang-${VERSION}-vc14_20180208.tar.bz2"
            "openmp-${VERSION}-vc14_1.tar.bz2"
            "flang-${VERSION}-vc14_20180208.tar.bz2"
        )

        set(HASHES
            "fd5eb1d39ba631e2e85ecf63906c8a5d0f87e5f3f9a86dbe4cfd28d399e922f9786804f94f2a3372d13c9c4f01d9d253fba31d9695be815b4798108db17939b4"
            "a8bcb44b344c9ca3571e1de08894d9ee450e2a36e9a604dedb264415adbabb9b0b698b39d96abc8b319041b15ba991b28d463a61523388509038a363cbaebae2"
            "5277f0a33d8672b711bbf6c97c9e2e755aea411bfab2fce4470bb2dd112cbbb11c913de2062331cc61c3acf7b294a6243148d7cb71b955cc087586a2f598809a"
            "c72a4532dfc666ad301e1349c1ff0f067049690f53dbf30fd38382a546b619045a34660ee9591ce5c91cf2a937af59e87d0336db2ee7f59707d167cd92a920c4"
        )

        set(REQUIRED_LIBRARY_PATH "${DOWNLOADS}/tools/flang/${VERSION}/Library/lib")
        set(REQUIRED_BINARY_PATH "${DOWNLOADS}/tools/flang/${VERSION}/Library/bin")
      elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        set(VERSION "7.0.0")
        set(URL https://github.com/flang-compiler/flang/releases/download/flang_20190329/flang-20190329-x86-70.tgz)
        set(ARCHIVE "flang-20190329-x86-70.tgz")
        set(HASH "4e6f4ced56a10405dd6b556b5a3f1f294db544fe84e6a7a165abccfaa58f192badaacd90f079fd496e2405a84b49bbbc965505ca868bb9c9ccba78df315938ad")
        set(REQUIRED_LIBRARY_PATH "${DOWNLOADS}/tools/flang/${VERSION}/lib")
        set(REQUIRED_BINARY_PATH "${DOWNLOADS}/tools/flang/${VERSION}/bin")
      endif()
    else()
      message(FATAL "Flang can only target 64-bit architectures.")
    endif()

    set(PROGNAME flang)
    set(SUBDIR ${VERSION})
    set(PATHS ${DOWNLOADS}/tools/flang/${VERSION}/bin)
    set(SKIP_PACKAGE_MANAGER TRUE)
  else()
    message(FATAL "unknown tool ${VAR} -- unable to acquire.")
  endif()

  if(NOT DEFINED ARCHIVES)
    set(ARCHIVES ${ARCHIVE})
  endif()

  if(NOT DEFINED HASHES)
    set(HASHES ${HASH})
  endif()

  if(NOT DEFINED URL_VARS)
    set(URL_VARS URL)
  endif()

  macro(do_find)
    if(NOT DEFINED REQUIRED_INTERPRETER)
      find_program(${VAR} ${PROGNAME} PATHS ${PATHS} ${FIND_OPTIONS})
    else()
      vcpkg_find_acquire_program(${REQUIRED_INTERPRETER})
      find_file(SCRIPT ${SCRIPTNAME} PATHS ${PATHS})
      set(${VAR} ${${REQUIRED_INTERPRETER}} ${SCRIPT})
    endif()
  endmacro()

  do_find()
  if("${${VAR}}" MATCHES "-NOTFOUND")
    if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows" AND NOT SKIP_PACKAGE_MANAGER)
      set(EXAMPLE ".")
      if(DEFINED BREW_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        set(EXAMPLE ":\n    brew install ${BREW_PACKAGE_NAME}")
      elseif(DEFINED APT_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        set(EXAMPLE ":\n    sudo apt-get install ${APT_PACKAGE_NAME}")
      endif()
      message(FATAL_ERROR "Could not find ${PROGNAME}. Please install it via your package manager${EXAMPLE}")
    endif()

    list(LENGTH ARCHIVES ARCHIVES_LENGTH)
    list(LENGTH HASHES HASHES_LENGTH)
    list(LENGTH URL_VARS URL_VARS_LENGTH)

    if(ARCHIVES_LENGTH GREATER HASHES_LENGTH)
      message(FATAL_ERROR "A hash must be provided for every archive")
    endif()

    if(ARCHIVES_LENGTH GREATER URL_VARS_LENGTH)
        message(FATAL_ERROR "A list of URLS must be provided for every archive")
    endif()

    math(EXPR ARCHIVES_LENGTH "${ARCHIVES_LENGTH}-1")

    foreach(ARCHIVE_IDX RANGE ${ARCHIVES_LENGTH})
      list(GET ARCHIVES $ARCHIVE_IDX ARCHIVE)
      list(GET HASHES $ARCHIVE_IDX HASH)
      list(GET URL_VARS $ARCHIVE_IDX URL_VAR)
      set(URLS ${${URL_VAR}})

      vcpkg_download_distfile(
          ARCHIVE_PATH
          URLS ${URLS}
          SHA512 ${HASH}
          FILENAME ${ARCHIVE}
      )

      set(PROG_PATH_SUBDIR "${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}")
      file(MAKE_DIRECTORY ${PROG_PATH_SUBDIR})
      if(DEFINED NOEXTRACT)
        if(DEFINED _vfa_RENAME)
          file(INSTALL ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR} RENAME ${_vfa_RENAME})
        else()
          file(COPY ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR})
        endif()
      else()
        get_filename_component(ARCHIVE_EXTENSION ${ARCHIVE} EXT)
        string(TOLOWER "${ARCHIVE_EXTENSION}" ARCHIVE_EXTENSION)
        if(ARCHIVE_EXTENSION STREQUAL ".msi")
          file(TO_NATIVE_PATH "${ARCHIVE_PATH}" ARCHIVE_NATIVE_PATH)
          file(TO_NATIVE_PATH "${PROG_PATH_SUBDIR}" DESTINATION_NATIVE_PATH)
          execute_process(
            COMMAND msiexec /a ${ARCHIVE_NATIVE_PATH} /qn TARGETDIR=${DESTINATION_NATIVE_PATH}
            WORKING_DIRECTORY ${DOWNLOADS}
          )
        else()
          execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
            WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
          )
        endif()
      endif()

      do_find()
    endforeach()
  endif()

  set(${VAR} "${${VAR}}" PARENT_SCOPE)

  message("${REQUIRED_BINARY_PATH}")

  if(DEFINED _vfa_REQUIRED_LIBRARY_PATH_VAR)
    set(${_vfa_REQUIRED_LIBRARY_PATH_VAR} ${REQUIRED_LIBRARY_PATH} PARENT_SCOPE)
  endif()

  if(DEFINED _vfa_REQUIRED_BINARY_PATH_VAR)
    set(${_vfa_REQUIRED_BINARY_PATH_VAR} ${REQUIRED_BINARY_PATH} PARENT_SCOPE)
  endif()

  if(DEFINED _vfa_VERSION_VAR)
    set(${_vfa_VERSION_VAR} ${VERSION} PARENT_SCOPE)
  endif()
endfunction()
