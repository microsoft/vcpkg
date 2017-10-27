## # vcpkg_find_acquire_program
##
## Download or find a well-known tool.
##
## ## Usage
## ```cmake
## vcpkg_find_acquire_program(<VAR>)
## ```
## ## Parameters
## ### VAR
## This variable specifies both the program to be acquired as well as the out parameter that will be set to the path of the program executable.
##
## ## Notes
## The current list of programs includes:
##
## - 7Z
## - BISON
## - FLEX
## - GASPREPROCESSOR
## - PERL
## - PYTHON2
## - PYTHON3
## - JOM
## - MESON
## - NASM
## - NINJA
## - YASM
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

  unset(NOEXTRACT)
  unset(SUBDIR)
  unset(REQUIRED_INTERPRETER)

  vcpkg_get_program_files_platform_bitness(PROGRAM_FILES_PLATFORM_BITNESS)
  vcpkg_get_program_files_32_bit(PROGRAM_FILES_32_BIT)

  if(VAR MATCHES "PERL")
    set(PROGNAME perl)
    set(PATHS ${DOWNLOADS}/tools/perl/perl/bin)
    set(URL "http://strawberryperl.com/download/5.24.1.1/strawberry-perl-5.24.1.1-32bit-portable.zip")
    set(ARCHIVE "strawberry-perl-5.24.1.1-32bit-portable.zip")
    set(HASH a6e685ea24376f50db5f06c5b46075f1d3be25168fa1f27fa9b02e2ac017826cee62a2b43562f9b6c989337a231ba914416c110075457764de2d11f99d5e0f26)
  elseif(VAR MATCHES "NASM")
    set(PROGNAME nasm)
    set(PATHS ${DOWNLOADS}/tools/nasm/nasm-2.12.02)
    set(URL "http://www.nasm.us/pub/nasm/releasebuilds/2.12.02/win32/nasm-2.12.02-win32.zip")
    set(ARCHIVE "nasm-2.12.02-win32.zip")
    set(HASH df7aaba094e17832688c88993997612a2e2c96cc3dc14ca3e8347b44c7762115f5a7fc6d7f20be402553aaa4c9e43ddfcf6228f581cfe89289bae550de151b36)
  elseif(VAR MATCHES "YASM")
    set(PROGNAME yasm)
    set(PATHS ${DOWNLOADS}/tools/yasm)
    set(URL "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win32.exe")
    set(ARCHIVE "yasm.exe")
    set(NOEXTRACT ON)
    set(HASH 850b26be5bbbdaeaf45ac39dd27f69f1a85e600c35afbd16b9f621396b3c7a19863ea3ff316b025b578fce0a8280eef2203306a2b3e46ee1389abb65313fb720)
  elseif(VAR MATCHES "PYTHON3")
    set(PROGNAME python)
    set(SUBDIR "python3")
    set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
    set(URL "https://www.python.org/ftp/python/3.5.4/python-3.5.4-embed-win32.zip")
    set(ARCHIVE "python-3.5.4-embed-win32.zip")
    set(HASH b5240fdc95088c2d7f65d2dd598650f8dd106b49589d94156bd4a078b108c6cabbe7a38ef73e2b2cf00e8312a93d2e587eac2c54ce85540d3c7a26cc60013156)
  elseif(VAR MATCHES "PYTHON2")
    set(PROGNAME python)
    set(SUBDIR "python2")
    set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
    file(TO_NATIVE_PATH "${PATHS}" DESTINATION_NATIVE_PATH)
    set(URL "https://www.python.org/ftp/python/2.7.14/python-2.7.14.msi")
    set(ARCHIVE "python2.msi")
    set(HASH 8c3ad6e527742d99ba96dcfd1098861b14e7207b80d51a54e9b410ab2f36e44e05561ea1527d8e92b3e10808311536260bd9e82db0da3b513fb1be18e108510e)
  elseif(VAR MATCHES "RUBY")
    set(PROGNAME "ruby")
    set(PATHS ${DOWNLOADS}/tools/ruby/rubyinstaller-2.4.1-1-x86/bin)
    set(URL https://github.com/oneclick/rubyinstaller2/releases/download/2.4.1-1/rubyinstaller-2.4.1-1-x86.7z)
    set(ARCHIVE rubyinstaller-2.4.1-1-x86.7z)
    set(HASH b51112e9b58cfcbe8cec0607e8a16fff6a943d9b4e31b2a7fbf5df5f83f050bf0a4812d3dd6000ff21a3d5fd219cd0a309c58ac1c1db950a9b0072405e4b70f5)
  elseif(VAR MATCHES "JOM")
    set(PROGNAME jom)
    set(SUBDIR "jom-1.1.2")
    set(PATHS ${DOWNLOADS}/tools/jom/${SUBDIR})
    set(URL "http://download.qt.io/official_releases/jom/jom_1_1_2.zip")
    set(ARCHIVE "jom_1_1_2.zip")
    set(HASH 830cd94ed6518fbe4604a0f5a3322671b4674b87d25a71349c745500d38e85c0fac4f6995242fc5521eb048e3966bb5ec2a96a06b041343ed8da9bba78124f34)
  elseif(VAR MATCHES "7Z")
    set(PROGNAME 7z)
    set(PATHS "${PROGRAM_FILES_PLATFORM_BITNESS}/7-Zip" "${PROGRAM_FILES_32_BIT}/7-Zip" ${DOWNLOADS}/tools/7z/Files/7-Zip)
    set(URL "http://7-zip.org/a/7z1604.msi")
    set(ARCHIVE "7z1604.msi")
    set(HASH 556f95f7566fe23704d136239e4cf5e2a26f939ab43b44145c91b70d031a088d553e5c21301f1242a2295dcde3143b356211f0108c68e65eef8572407618326d)
  elseif(VAR MATCHES "NINJA")
    set(PROGNAME ninja)
    set(SUBDIR "ninja-1.8.2")
    set(PATHS ${DOWNLOADS}/tools/ninja/${SUBDIR})
    set(URL "https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-win.zip")
    set(ARCHIVE "ninja-1.8.2-win.zip")
    set(HASH 9b9ce248240665fcd6404b989f3b3c27ed9682838225e6dc9b67b551774f251e4ff8a207504f941e7c811e7a8be1945e7bcb94472a335ef15e23a0200a32e6d5)
  elseif(VAR MATCHES "MESON")
    set(PROGNAME meson)
    set(REQUIRED_INTERPRETER PYTHON3)
    set(SCRIPTNAME meson.py)
    set(PATHS ${DOWNLOADS}/tools/meson/meson-0.43.0)
    set(URL "https://github.com/mesonbuild/meson/archive/0.43.0.zip")
    set(ARCHIVE "meson-0.43.0.zip")
    set(HASH dde4de72eff37046731224f32aa5f4618d45bdf148cec2d1af6e25e7522ebc2b04aedc9eceed483dfa93823a0ea7ea472d0c0c9380061bf3ee2f16b87dd1425e)
  elseif(VAR MATCHES "FLEX")
    set(PROGNAME win_flex)
    set(PATHS ${DOWNLOADS}/tools/win_flex)
    set(URL "https://sourceforge.net/projects/winflexbison/files/win_flex_bison-2.5.9.zip/download")
    set(ARCHIVE "win_flex_bison-2.5.9.zip")
    set(HASH 9580f0e46893670a011645947c1becda69909a41a38bb4197fe33bd1ab7719da6b80e1be316f269e1a4759286870d49a9b07ef83afc4bac33232bd348e0bc814)
  elseif(VAR MATCHES "BISON")
    set(PROGNAME win_bison)
    set(PATHS ${DOWNLOADS}/tools/win_bison)
    set(URL "https://sourceforge.net/projects/winflexbison/files/win_flex_bison-2.5.9.zip/download")
    set(ARCHIVE "win_flex_bison-2.5.9.zip")
    set(HASH 9580f0e46893670a011645947c1becda69909a41a38bb4197fe33bd1ab7719da6b80e1be316f269e1a4759286870d49a9b07ef83afc4bac33232bd348e0bc814)
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
    set(URL "https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/36bacb4cba27003c572e5bf7a9c4dfe3c9a8d40d/gas-preprocessor.pl")
    set(ARCHIVE "gas-preprocessor.pl")
    set(HASH a25caadccd1457a0fd2abb5a0da9aca1713b2c351d76daf87a4141e52021f51aa09e95a62942c6f0764f79cc1fa65bf71584955b09e62ee7da067b5c82baf6b3)
  elseif(VAR MATCHES "DARK")
    set(PROGNAME dark)
    set(SUBDIR "wix311-binaries")
    set(PATHS ${DOWNLOADS}/tools/dark/${SUBDIR})
    set(URL "https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311-binaries.zip")
    set(ARCHIVE "wix311-binaries.zip")
    set(HASH 74f0fa29b5991ca655e34a9d1000d47d4272e071113fada86727ee943d913177ae96dc3d435eaf494d2158f37560cd4c2c5274176946ebdb17bf2354ced1c516)
  else()
    message(FATAL "unknown tool ${VAR} -- unable to acquire.")
  endif()

  macro(do_find)
    if(NOT DEFINED REQUIRED_INTERPRETER)
      find_program(${VAR} ${PROGNAME} PATHS ${PATHS})
    else()
      vcpkg_find_acquire_program(${REQUIRED_INTERPRETER})
      find_file(SCRIPT ${SCRIPTNAME} PATHS ${PATHS})
      set(${VAR} ${${REQUIRED_INTERPRETER}} ${SCRIPT})
    endif()
  endmacro()

  do_find()
  if("${${VAR}}" MATCHES "-NOTFOUND")
    file(DOWNLOAD ${URL} ${DOWNLOADS}/${ARCHIVE}
      EXPECTED_HASH SHA512=${HASH}
      SHOW_PROGRESS
    )
    file(MAKE_DIRECTORY ${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR})
    if(DEFINED NOEXTRACT)
      file(COPY ${DOWNLOADS}/${ARCHIVE} DESTINATION ${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR})
    else()
      get_filename_component(ARCHIVE_EXTENSION ${ARCHIVE} EXT)
      string(TOLOWER "${ARCHIVE_EXTENSION}" ARCHIVE_EXTENSION)
      if(ARCHIVE_EXTENSION STREQUAL ".msi")
        file(TO_NATIVE_PATH "${DOWNLOADS}/${ARCHIVE}" ARCHIVE_NATIVE_PATH)
        file(TO_NATIVE_PATH "${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}" DESTINATION_NATIVE_PATH)
        execute_process(
          COMMAND msiexec /a ${ARCHIVE_NATIVE_PATH} /qn TARGETDIR=${DESTINATION_NATIVE_PATH}
          WORKING_DIRECTORY ${DOWNLOADS}
        )
      else()
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E tar xzf ${DOWNLOADS}/${ARCHIVE}
          WORKING_DIRECTORY ${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}
        )
      endif()
    endif()

    do_find()
  endif()

  set(${VAR} "${${VAR}}" PARENT_SCOPE)
endfunction()
