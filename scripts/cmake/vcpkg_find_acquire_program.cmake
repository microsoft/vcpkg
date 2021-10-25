#[===[.md:
# vcpkg_find_acquire_program

Download or find a well-known tool.

## Usage
```cmake
vcpkg_find_acquire_program(<VAR>)
```
## Parameters
### VAR
This variable specifies both the program to be acquired as well as the out parameter that will be set to the path of the program executable.

## Notes
The current list of programs includes:

* 7Z
* ARIA2 (Downloader)
* BISON
* CLANG
* DARK
* DOXYGEN
* FLEX
* GASPREPROCESSOR
* GPERF
* PERL
* PYTHON2
* PYTHON3
* GIT
* GN
* GO
* JOM
* MESON
* NASM
* NINJA
* NUGET
* SCONS
* SWIG
* YASM

Note that msys2 has a dedicated helper function: [`vcpkg_acquire_msys`](vcpkg_acquire_msys.md).

## Examples

* [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
* [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
* [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)
#]===]

include(vcpkg_execute_in_download_mode)

function(vcpkg_find_acquire_program VAR)
  set(EXPANDED_VAR ${${VAR}})
  if(EXPANDED_VAR)
    return()
  endif()

  unset(NOEXTRACT)
  unset(_vfa_RENAME)
  unset(SUBDIR)
  unset(PROG_PATH_SUBDIR)
  unset(REQUIRED_INTERPRETER)
  unset(_vfa_SUPPORTED)
  unset(POST_INSTALL_COMMAND)
  unset(PATHS)

  if(VAR MATCHES "PERL")
    set(PROGNAME perl)
    set(PERL_VERSION 5.32.1.1)
    set(SUBDIR ${PERL_VERSION})
    set(PATHS ${DOWNLOADS}/tools/perl/${SUBDIR}/perl/bin)
    set(BREW_PACKAGE_NAME "perl")
    set(APT_PACKAGE_NAME "perl")
    set(URL
      "https://strawberryperl.com/download/${PERL_VERSION}/strawberry-perl-${PERL_VERSION}-32bit.zip"
    )
    set(ARCHIVE "strawberry-perl-${PERL_VERSION}-32bit.zip")
    set(HASH 936381254fea2e596db6a16c23b08ced25c4081fda484e1b8c4356755016e4b956bd00f3d2ee651d5f41a7695e9998f6c1ac3f4a237212b9c55aca8c5fea14e9)
  elseif(VAR MATCHES "NASM")
    set(PROGNAME nasm)
    set(NASM_VERSION 2.15.05)
    set(PATHS ${DOWNLOADS}/tools/nasm/nasm-${NASM_VERSION})
    set(BREW_PACKAGE_NAME "nasm")
    set(APT_PACKAGE_NAME "nasm")
    set(URL
      "https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/win32/nasm-${NASM_VERSION}-win32.zip"
      "https://fossies.org/windows/misc/nasm-${NASM_VERSION}-win32.zip"
    )
    set(ARCHIVE "nasm-${NASM_VERSION}-win32.zip")
    set(HASH 9412b8caa07e15eac8f500f6f8fab9f038d95dc25e0124b08a80645607cf5761225f98546b52eac7b894420d64f26c3cbf22c19cd286bbe583f7c964256c97ed)
  elseif(VAR MATCHES "YASM")
    set(PROGNAME yasm)
    set(YASM_VERSION 1.3.0.6.g1962)
    set(SUBDIR 1.3.0.6)
    set(BREW_PACKAGE_NAME "yasm")
    set(APT_PACKAGE_NAME "yasm")
    set(URL "https://www.tortall.net/projects/yasm/snapshots/v${YASM_VERSION}/yasm-${YASM_VERSION}.exe")
    set(ARCHIVE "yasm-${YASM_VERSION}.exe")
    set(_vfa_RENAME "yasm.exe")
    set(NOEXTRACT ON)
    set(HASH c1945669d983b632a10c5ff31e86d6ecbff143c3d8b2c433c0d3d18f84356d2b351f71ac05fd44e5403651b00c31db0d14615d7f9a6ecce5750438d37105c55b)
  elseif(VAR MATCHES "GIT")
    set(PROGNAME git)
    if(CMAKE_HOST_WIN32)
      set(GIT_BASE_VERSION 2.32.0)
      set(GIT_VERSION 2.32.0.2)
      set(SUBDIR "git-${GIT_VERSION}-2-windows")
      set(URL "https://github.com/git-for-windows/git/releases/download/v${GIT_BASE_VERSION}.windows.2/PortableGit-${GIT_VERSION}-32-bit.7z.exe")
      set(ARCHIVE "PortableGit-${GIT_VERSION}-32-bit.7z.exe")
      set(HASH 867d8534972cbaf7a4224e25a14d484f8d17ef186f8d79e9a758afb90cf69541375cb7615a39702311f4809cb8371ef85c2b1a15bfffe9e48f0e597ac011b348)
      set(PATHS
        "${DOWNLOADS}/tools/${SUBDIR}/mingw32/bin"
        "${DOWNLOADS}/tools/git/${SUBDIR}/mingw32/bin")
    else()
      set(BREW_PACKAGE_NAME "git")
      set(APT_PACKAGE_NAME "git")
    endif()
  elseif(VAR MATCHES "GN")
    set(PROGNAME gn)
    set(_vfa_RENAME "gn")
    set(CIPD_DOWNLOAD_GN "https://chrome-infra-packages.appspot.com/dl/gn/gn")
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      set(_vfa_SUPPORTED ON)
      set(GN_VERSION "xus7xtaPhpv5vCmKFOnsBVoB-PKmhZvRsSTjbQAuF0MC")
      set(GN_PLATFORM "linux-amd64")
      set(HASH "871e75d7f3597b74fb99e36bb41fe5a9f8ce8a4d9f167f4729fc6e444807a59f35ec8aca70c2274a99c79d70a1108272be1ad991678a8ceb39e30f77abb13135")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(_vfa_SUPPORTED ON)
      set(GN_VERSION "qhxILDNcJ2H44HfHmfiU-XIY3E_SIXvFqLd2wvbIgOoC")
      set(GN_PLATFORM "mac-amd64")
      set(HASH "03ee64cb15bae7fceb412900d470601090bce147cfd45eb9b46683ac1a5dca848465a5d74c55a47df7f0e334d708151249a6d37bb021de74dd48b97ed4a07937")
    else()
      set(GN_VERSION "qUkAhy9J0P7c5racy-9wB6AHNK_btS18im8S06_ehhwC")
      set(GN_PLATFORM "windows-amd64")
      set(HASH "263e02bd79eee0cb7b664831b7898565c5656a046328d8f187ef7ae2a4d766991d477b190c9b425fcc960ab76f381cd3e396afb85cba7408ca9e74eb32c175db")
    endif()
    set(SUBDIR "${GN_VERSION}")
    set(URL "${CIPD_DOWNLOAD_GN}/${GN_PLATFORM}/+/${GN_VERSION}")
    set(ARCHIVE "gn-${GN_PLATFORM}.zip")
  elseif(VAR MATCHES "GO")
    set(PROGNAME go)
    set(SUBDIR 1.16.6.windows-386)
    set(PATHS ${DOWNLOADS}/tools/go/${SUBDIR}/go/bin)
    set(BREW_PACKAGE_NAME "go")
    set(APT_PACKAGE_NAME "golang-go")
    set(URL "https://dl.google.com/go/go${SUBDIR}.zip")
    set(ARCHIVE "go${SUBDIR}.zip")
    set(HASH 2a1e539ed628c0cca5935d24d22cf3a7165f5c80e12a4003ac184deae6a6d0aa31f582f3e8257b0730adfc09aeec3a0e62f4732e658c312d5382170bcd8c94d8)
  elseif(VAR MATCHES "PYTHON3")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME python)
      set(PYTHON_VERSION 3.10.0)
      if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(SUBDIR "python-${PYTHON_VERSION}-x86")
        set(URL "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-embed-win32.zip")
        set(ARCHIVE "python-${PYTHON_VERSION}-embed-win32.zip")
        set(HASH 0b007bfa02cdd48b3c260986493fa124a6b9d794da6eba2b4fad0d779fd655e9ae4e16daf5f02ff5b30a17abcfc1499bc6bee394c0f8abe933f2d4fe702af3cd)
      else()
        set(SUBDIR "python-${PYTHON_VERSION}-x64")
        set(URL "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-embed-amd64.zip")
        set(ARCHIVE "python-${PYTHON_VERSION}-embed-amd64.zip")
        set(HASH 23d81d007698383d8dc088da532dcb86c6ceca7eb78ba5688fc2e18ee7f33f53a5632282873762293b8164556dfb15870f8ffb7abd368faba0a3d8d5d5bc6297)
      endif()
      set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
      set(POST_INSTALL_COMMAND ${CMAKE_COMMAND} -E rm python310._pth)
    else()
      set(PROGNAME python3)
      set(BREW_PACKAGE_NAME "python")
      set(APT_PACKAGE_NAME "python3")
    endif()
  elseif(VAR MATCHES "PYTHON2")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME python)
      set(PYTHON_VERSION 2.7.18)
      if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(SUBDIR "python-${PYTHON_VERSION}-x86")
        set(URL "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}.msi")
        set(ARCHIVE "python-${PYTHON_VERSION}.msi")
        set(HASH 2c112733c777ddbf189b0a54047a9d5851ebce0564cc38b9687d79ce6c7a09006109dbad8627fb1a60c3ad55e261db850d9dfa454af0533b460b2afc316fe115)
      else()
        set(SUBDIR "python-${PYTHON_VERSION}-x64")
        set(URL "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}.amd64.msi")
        set(ARCHIVE "python-${PYTHON_VERSION}.amd64.msi")
        set(HASH 6a81a413b80fd39893e7444fd47efa455d240cbb77a456c9d12f7cf64962b38c08cfa244cd9c50a65947c40f936c6c8c5782f7236d7b92445ab3dd01e82af23e)
      endif()
      set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      # macOS includes Python 2.7 built-in as `python`
      set(PROGNAME python)
      set(BREW_PACKAGE_NAME "python2")
    else()
      set(PROGNAME python2)
      set(APT_PACKAGE_NAME "python")
    endif()
  elseif(VAR MATCHES "RUBY")
    set(PROGNAME "ruby")
    set(RUBY_VERSION 2.7.4-1)
    set(PATHS ${DOWNLOADS}/tools/ruby/rubyinstaller-${RUBY_VERSION}-x86/bin)
    set(URL https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-${RUBY_VERSION}/rubyinstaller-${RUBY_VERSION}-x86.7z)
    set(ARCHIVE rubyinstaller-${RUBY_VERSION}-x86.7z)
    set(HASH 4bf459c987b407bdda328c52d95060bf6ad48fc3e5ed5f64d4b205c5b4153c7a00cb6f9da6c0bcd5f2e001e9dc3dda0b72269ec4afdeffd658b93c085cd1d859)
  elseif(VAR MATCHES "JOM")
    set(PROGNAME jom)
    set(SUBDIR "jom-1.1.3")
    set(PATHS ${DOWNLOADS}/tools/jom/${SUBDIR})
    set(URL
      "https://download.qt.io/official_releases/jom/jom_1_1_3.zip"
      "https://mirrors.ocf.berkeley.edu/qt/official_releases/jom/jom_1_1_3.zip"
    )
    set(ARCHIVE "jom_1_1_3.zip")
    set(HASH 5b158ead86be4eb3a6780928d9163f8562372f30bde051d8c281d81027b766119a6e9241166b91de0aa6146836cea77e5121290e62e31b7a959407840fc57b33)
  elseif(VAR MATCHES "7Z")
    set(PROGNAME 7z)
    set(PATHS "${DOWNLOADS}/tools/7z/Files/7-Zip")
    set(URL "https://7-zip.org/a/7z1900.msi")
    set(ARCHIVE "7z1900.msi")
    set(HASH f73b04e2d9f29d4393fde572dcf3c3f0f6fa27e747e5df292294ab7536ae24c239bf917689d71eb10cc49f6b9a4ace26d7c122ee887d93cc935f268c404e9067)
  elseif(VAR MATCHES "NINJA")
    set(PROGNAME ninja)
    set(NINJA_VERSION 1.10.2)
    set(_vfa_SUPPORTED ON)
    if(CMAKE_HOST_WIN32)
      set(ARCHIVE "ninja-win-${NINJA_VERSION}.zip")
      set(SUBDIR "${NINJA_VERSION}-windows")
      set(URL "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-win.zip")
      set(HASH 6004140d92e86afbb17b49c49037ccd0786ce238f340f7d0e62b4b0c29ed0d6ad0bab11feda2094ae849c387d70d63504393714ed0a1f4d3a1f155af7a4f1ba3)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(ARCHIVE "ninja-mac-${NINJA_VERSION}.zip")
      set(URL "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-mac.zip")
      set(SUBDIR "${NINJA_VERSION}-osx")
      set(PATHS "${DOWNLOADS}/tools/ninja-${NINJA_VERSION}-osx")
      set(HASH bcd12f6a3337591306d1b99a7a25a6933779ba68db79f17c1d3087d7b6308d245daac08df99087ff6be8dc7dd0dcdbb3a50839a144745fa719502b3a7a07260b)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD")
      set(PATHS "${DOWNLOADS}/tools/${SUBDIR}-freebsd")
      set(_vfa_SUPPORTED OFF)
    else()
      set(ARCHIVE "ninja-linux-${NINJA_VERSION}.zip")
      set(URL "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip")
      set(SUBDIR "${NINJA_VERSION}-linux")
      set(PATHS "${DOWNLOADS}/tools/ninja-${NINJA_VERSION}-linux")
      set(HASH 93e802e9c17fb59636cddde4bad1ddaadad624f4ecfee00d5c78790330a4e9d433180e795718cda27da57215ce643c3929cf72c85337ee019d868c56f2deeef3)
    endif()
    set(VERSION_CMD --version)
  elseif(VAR MATCHES "NUGET")
    set(PROGNAME nuget)
    set(SUBDIR "5.10.0")
    set(PATHS "${DOWNLOADS}/tools/nuget-${SUBDIR}-windows")
    set(BREW_PACKAGE_NAME "nuget")
    set(URL "https://dist.nuget.org/win-x86-commandline/v5.10.0/nuget.exe")
    set(_vfa_RENAME "nuget.exe")
    set(ARCHIVE "nuget.5.10.0.exe")
    set(NOEXTRACT ON)
    set(HASH c4b7375e46cdb843096ce491b9809e0dc86773ba7b6333f13d49ec414b2953112df82ee8b833fd31be0cc7fe0fff1af88f3c07aa9553ad03f7f6c5a6eec2057e)
  elseif(VAR MATCHES "MESON")
    set(MESON_VERSION 0.58.1)
    set(PROGNAME meson)
    set(REQUIRED_INTERPRETER PYTHON3)
    set(APT_PACKAGE_NAME "meson")
    set(BREW_PACKAGE_NAME "meson")
    set(SCRIPTNAME meson meson.py)
    set(REF aeda7f249c4a5dbbecc52e44f382246a2377b5b0)
    set(PATHS ${DOWNLOADS}/tools/meson/meson-${REF})
    set(URL "https://github.com/mesonbuild/meson/archive/${REF}.tar.gz")
    set(ARCHIVE "meson-${REF}.tar.gz")
    #set(PATHS ${DOWNLOADS}/tools/meson/meson-${MESON_VERSION})
    #set(URL "https://github.com/mesonbuild/meson/releases/download/${MESON_VERSION}/meson-${MESON_VERSION}.tar.gz")
    #set(ARCHIVE "meson-${MESON_VERSION}.tar.gz")
    set(HASH 18a012a45274dbb4582e99fd69d920f38831e788d9860f9553c64847bedb1c2010ae0b5c0ef4a4350c03f5e0f95aaa0395378e1208109b59640c1a70b1e202d2)
    set(_vfa_SUPPORTED ON)
    set(VERSION_CMD --version)
  elseif(VAR MATCHES "FLEX" OR VAR MATCHES "BISON")
    if(CMAKE_HOST_WIN32)
      set(SOURCEFORGE_ARGS
        REPO winflexbison
        FILENAME winflexbison-2.5.16.zip
        SHA512 0a14154bff5d998feb23903c46961528f8ccb4464375d5384db8c4a7d230c0c599da9b68e7a32f3217a0a0735742242eaf3769cb4f03e00931af8640250e9123
        NO_REMOVE_ONE_LEVEL
        WORKING_DIRECTORY "${DOWNLOADS}/tools/winflexbison"
      )
      if(VAR MATCHES "FLEX")
        set(PROGNAME win_flex)
      else()
        set(PROGNAME win_bison)
      endif()
      set(PATHS ${DOWNLOADS}/tools/winflexbison/0a14154bff-a8cf65db07)
      if(NOT EXISTS "${PATHS}/data/m4sugar/m4sugar.m4")
        file(REMOVE_RECURSE "${PATHS}")
      endif()
    elseif(VAR MATCHES "FLEX")
      set(PROGNAME flex)
      set(APT_PACKAGE_NAME flex)
      set(BREW_PACKAGE_NAME flex)
    else()
      set(PROGNAME bison)
      set(APT_PACKAGE_NAME bison)
      set(BREW_PACKAGE_NAME bison)
      if (APPLE)
        set(PATHS /usr/local/opt/bison/bin)
      endif()
    endif()
  elseif(VAR MATCHES "CLANG")
    set(PROGNAME clang)
    set(SUBDIR "clang-12.0.0")
    set(LLVM_VERSION 12.0.0)
    if(CMAKE_HOST_WIN32)
      set(PATHS
        # Support LLVM in Visual Studio 2019
        "$ENV{LLVMInstallDir}/x64/bin"
        "$ENV{LLVMInstallDir}/bin"
        "$ENV{VCINSTALLDIR}/Tools/Llvm/x64/bin"
        "$ENV{VCINSTALLDIR}/Tools/Llvm/bin"
        "${DOWNLOADS}/tools/${SUBDIR}-windows/bin"
        "${DOWNLOADS}/tools/clang/${SUBDIR}/bin")

      if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(HOST_ARCH_ $ENV{PROCESSOR_ARCHITEW6432})
      else()
        set(HOST_ARCH_ $ENV{PROCESSOR_ARCHITECTURE})
      endif()

      if(HOST_ARCH_ MATCHES "64")
        set(URL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/LLVM-${LLVM_VERSION}-win64.exe")
        set(ARCHIVE "LLVM-${LLVM_VERSION}-win64.7z.exe")
        set(HASH 67a9b54abad5143fa5f79f0cfc184be1394c9fc894fa9cee709943cb6ccbde8f0ea6003d8fcc20eccf035631abe4009cc0f694ac84e7879331cebba8125e4c7f)
      else()
        set(URL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/LLVM-${LLVM_VERSION}-win32.exe")
        set(ARCHIVE "LLVM-${LLVM_VERSION}-win32.7z.exe")
        set(HASH 92fa5252fd08c1414ee6d71e2544cd2c44872124c47225f8d98b3af711d20e699f2888bc30642dfd00e005013da1607a593674fb4878951cc434694f9a119199)
      endif()
    endif()
    set(BREW_PACKAGE_NAME "llvm")
    set(APT_PACKAGE_NAME "clang")
  elseif(VAR MATCHES "GPERF")
    set(PROGNAME gperf)
    set(GPERF_VERSION 3.0.1)
    set(PATHS ${DOWNLOADS}/tools/gperf/bin)
    set(URL "https://sourceforge.net/projects/gnuwin32/files/gperf/${GPERF_VERSION}/gperf-${GPERF_VERSION}-bin.zip/download")
    set(ARCHIVE "gperf-${GPERF_VERSION}-bin.zip")
    set(HASH 3f2d3418304390ecd729b85f65240a9e4d204b218345f82ea466ca3d7467789f43d0d2129fcffc18eaad3513f49963e79775b10cc223979540fa2e502fe7d4d9)
  elseif(VAR MATCHES "GASPREPROCESSOR")
    set(NOEXTRACT true)
    set(PROGNAME gas-preprocessor)
    set(SUBDIR "4daa6115")
    set(REQUIRED_INTERPRETER PERL)
    set(SCRIPTNAME "gas-preprocessor.pl")
    set(PATHS ${DOWNLOADS}/tools/gas-preprocessor/${SUBDIR})
    set(_vfa_RENAME "gas-preprocessor.pl")
    set(URL "https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/4daa611556a0558dfe537b4f7ad80f7e50a079c1/gas-preprocessor.pl")
    set(ARCHIVE "gas-preprocessor-${SUBDIR}.pl")
    set(HASH 2737ba3c1cf85faeb1fbfe015f7bad170f43a857a50a1b3d81fa93ba325d481f73f271c5a886ff8b7eef206662e19f0e9ef24861dfc608b67b8ea8a2062dc061)
  elseif(VAR MATCHES "DARK")
    set(PROGNAME dark)
    set(SUBDIR "wix311-binaries")
    set(PATHS ${DOWNLOADS}/tools/dark/${SUBDIR})
    set(URL "https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311-binaries.zip")
    set(ARCHIVE "wix311-binaries.zip")
    set(HASH 74f0fa29b5991ca655e34a9d1000d47d4272e071113fada86727ee943d913177ae96dc3d435eaf494d2158f37560cd4c2c5274176946ebdb17bf2354ced1c516)
  elseif(VAR MATCHES "SCONS")
    set(PROGNAME scons)
    set(SCONS_VERSION 4.1.0)
    set(SUBDIR ${SCONS_VERSION})
    set(REQUIRED_INTERPRETER PYTHON2)
    set(SCRIPTNAME "scons.py")
    set(URL "https://sourceforge.net/projects/scons/files/scons-local-${SCONS_VERSION}.zip/download")
    set(ARCHIVE "scons-local-${SCONS_VERSION}.zip")
    set(HASH b173176ce8aca25039c64fcc68ec1b9ad31e03a926fd545e7631b3f9b374d914adffc593f505e3e7e2867b0ffe85e8deb0b39afe314edf05d02974ce5db1badb)
  elseif(VAR MATCHES "SWIG")
    set(SWIG_VERSION 4.0.2)
    set(PROGNAME swig)
    if(CMAKE_HOST_WIN32)
      set(SOURCEFORGE_ARGS
        REPO swig/swigwin
        REF swigwin-${SWIG_VERSION}
        FILENAME "swigwin-${SWIG_VERSION}.zip"
        SHA512 b8f105f9b9db6acc1f6e3741990915b533cd1bc206eb9645fd6836457fd30789b7229d2e3219d8e35f2390605ade0fbca493ae162ec3b4bc4e428b57155db03d
        NO_REMOVE_ONE_LEVEL
        WORKING_DIRECTORY "${DOWNLOADS}/tools/swig"
      )
      set(SUBDIR b8f105f9b9-f0518bc3b7/swigwin-${SWIG_VERSION})
    else()
      set(APT_PACKAGE_NAME "swig")
      set(BREW_PACKAGE_NAME "swig")
    endif()

  elseif(VAR MATCHES "DOXYGEN")
    set(PROGNAME doxygen)
    set(DOXYGEN_VERSION 1.9.1)
    set(SOURCEFORGE_ARGS
        REPO doxygen
        REF rel-${DOXYGEN_VERSION}
        FILENAME "doxygen-${DOXYGEN_VERSION}.windows.bin.zip"
        SHA512 c3eeb6b9fa4eab70fb6b0864fbbf94fb8050f3fee38d117cf470921a80e3569cc1c8b0272604d6731e05f01790cfaa70e159bec5d0882fc4f2d8ae4a5d52a21b
        NO_REMOVE_ONE_LEVEL
        WORKING_DIRECTORY "${DOWNLOADS}/tools/doxygen"
     )
    set(SUBDIR c3eeb6b9fa-76d69c6db5)
  elseif(VAR MATCHES "BAZEL")
    set(PROGNAME bazel)
    set(BAZEL_VERSION 4.1.0)
    set(_vfa_RENAME "bazel")
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      set(_vfa_SUPPORTED ON)
      set(SUBDIR ${BAZEL_VERSION}-linux)
      set(URL "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${SUBDIR}-x86_64")
      set(ARCHIVE "bazel-${SUBDIR}-x86_64")
      set(NOEXTRACT ON)
      set(HASH 50aa0894dbeedb9189a56f17baa8cecfa55c5f9c1f93a61b9ab5e10984754a400884fc9802b4979f536778e15f813a72807396b4b47694e4c05eadb841361c69)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(_vfa_SUPPORTED ON)
      set(SUBDIR ${BAZEL_VERSION}-darwin)
      set(URL "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${SUBDIR}-x86_64")
      set(ARCHIVE "bazel-${SUBDIR}-x86_64")
      set(NOEXTRACT ON)
      set(HASH 3500560c9d49d37a1ead2d2777d673c6f1874582883e141ecd5b3991005b1b6b8aab5f255c187133d771497c2a956f5c1e0dfad04dc453525634537e65b649af)
    else()
      set(SUBDIR ${BAZEL_VERSION}-windows)
      set(URL "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${SUBDIR}-x86_64.zip")
      set(ARCHIVE "bazel-${SUBDIR}-x86_64.zip")
      set(HASH 3954ab54b465d62eef397767dac7ce21d06ac8ea3e1571d0e7b1f0ea8b5c2cf44eea5d252b85a63a1e1a08dbe9a219783cc23c2888673c35e2df03edfdc9e5a7)
    endif()
  elseif(VAR MATCHES "ARIA2")
    set(PROGNAME aria2c)
    set(ARIA2_VERSION 1.35.0)
    set(PATHS ${DOWNLOADS}/tools/aria2c/aria2-${ARIA2_VERSION}-win-32bit-build1)
    set(URL "https://github.com/aria2/aria2/releases/download/release-${ARIA2_VERSION}/aria2-${ARIA2_VERSION}-win-32bit-build1.zip")
    set(ARCHIVE "aria2-${ARIA2_VERSION}-win-32bit-build1.zip")
    set(HASH 933537cad820b1cecf43a9eeca7e1b241dd7b1c902ee942441a166f2c38845f16046321efbdfa2f83c7e9fc50c7ecc5da6fd00e0c6e2124c07d3b783aa5092a4)
  elseif(VAR MATCHES "PKGCONFIG")
    set(PROGNAME pkg-config)
    if(ENV{PKG_CONFIG})
      debug_message(STATUS "PKG_CONFIG found in ENV! Using $ENV{PKG_CONFIG}")
      set(PKGCONFIG $ENV{PKG_CONFIG} PARENT_SCOPE)
      return()
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "OpenBSD")
      # As of 6.8, the OpenBSD specific pkg-config doesn't support {pcfiledir}
      set(_vfa_SUPPORTED ON)
      set(_vfa_RENAME "pkg-config")
      set(PKGCONFIG_VERSION 0.29.2.1)
      set(NOEXTRACT ON)
      set(ARCHIVE "pkg-config.openbsd")
      set(SUBDIR "openbsd")
      set(URL "https://raw.githubusercontent.com/jgilje/pkg-config-openbsd/master/pkg-config")
      set(HASH b7ec9017b445e00ae1377e36e774cf3f5194ab262595840b449832707d11e443a102675f66d8b7e8b2e2f28cebd6e256835507b1e0c69644cc9febab8285080b)
      set(VERSION_CMD --version)
    elseif(CMAKE_HOST_WIN32)
      if(NOT EXISTS "${PKGCONFIG}")
        set(VERSION 0.29.2-2)
        set(LIBWINPTHREAD_VERSION git-8.0.0.5906.c9a21571-1)
        vcpkg_acquire_msys(
          PKGCONFIG_ROOT
          NO_DEFAULT_PACKAGES
          DIRECT_PACKAGES
            "https://repo.msys2.org/mingw/i686/mingw-w64-i686-pkg-config-${VERSION}-any.pkg.tar.zst"
            54f8dad3b1a36a4515db47825a3214fbd2bd82f604aec72e7fb8d79068095fda3c836fb2296acd308522d6e12ce15f69e0c26dcf4eb0681fd105d057d912cdb7
            "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libwinpthread-${LIBWINPTHREAD_VERSION}-any.pkg.tar.zst"
            2c3d9e6b2eee6a4c16fd69ddfadb6e2dc7f31156627d85845c523ac85e5c585d4cfa978659b1fe2ec823d44ef57bc2b92a6127618ff1a8d7505458b794f3f01c
        )
      endif()
      set(${VAR} "${PKGCONFIG_ROOT}/mingw32/bin/pkg-config.exe" PARENT_SCOPE)
      return()
    else()
      set(BREW_PACKAGE_NAME pkg-config)
      set(APT_PACKAGE_NAME pkg-config)
      set(PATHS "/bin" "/usr/bin" "/usr/local/bin")
    endif()
  else()
    message(FATAL "unknown tool ${VAR} -- unable to acquire.")
  endif()

  macro(do_version_check)
    if(VERSION_CMD)
        vcpkg_execute_in_download_mode(
            COMMAND ${${VAR}} ${VERSION_CMD}
            WORKING_DIRECTORY ${VCPKG_ROOT_DIR}
            OUTPUT_VARIABLE ${VAR}_VERSION_OUTPUT
        )
        string(STRIP "${${VAR}_VERSION_OUTPUT}" ${VAR}_VERSION_OUTPUT)
        #TODO: REGEX MATCH case for more complex cases!
        if(NOT ${VAR}_VERSION_OUTPUT VERSION_GREATER_EQUAL ${VAR}_VERSION)
            message(STATUS "Found ${PROGNAME}('${${VAR}_VERSION_OUTPUT}') but at least version ${${VAR}_VERSION} is required! Trying to use internal version if possible!")
            unset(${VAR})
            set(${VAR} "${VAR}-NOTFOUND" CACHE INTERNAL "")
        else()
            message(STATUS "Found external ${PROGNAME}('${${VAR}_VERSION_OUTPUT}').")
        endif()
    endif()
  endmacro()

  macro(do_find)
    if(NOT DEFINED REQUIRED_INTERPRETER)
      find_program(${VAR} ${PROGNAME} PATHS ${PATHS} NO_DEFAULT_PATH)
      if(NOT ${VAR})
        find_program(${VAR} ${PROGNAME})
        if(${VAR} AND NOT ${VAR}_VERSION_CHECKED)
            do_version_check()
            set(${VAR}_VERSION_CHECKED ON)
        elseif(${VAR}_VERSION_CHECKED)
            message(FATAL_ERROR "Unable to find ${PROGNAME} with min version of ${${VAR}_VERSION}")
        endif()
      endif()
    else()
      vcpkg_find_acquire_program(${REQUIRED_INTERPRETER})
      find_file(SCRIPT_${VAR} NAMES ${SCRIPTNAME} PATHS ${PATHS} NO_DEFAULT_PATH)
      if(NOT SCRIPT_${VAR})
        find_file(SCRIPT_${VAR} NAMES ${SCRIPTNAME})
        if(SCRIPT_${VAR} AND NOT ${VAR}_VERSION_CHECKED)
            set(${VAR} ${${REQUIRED_INTERPRETER}} ${SCRIPT_${VAR}})
            do_version_check()
            set(${VAR}_VERSION_CHECKED ON)
            if(NOT ${VAR})
                unset(SCRIPT_${VAR} CACHE)
            endif()
        elseif(${VAR}_VERSION_CHECKED)
            message(FATAL_ERROR "Unable to find ${PROGNAME} with min version of ${${VAR}_VERSION}")
        endif()
      endif()
      if(SCRIPT_${VAR})
        set(${VAR} ${${REQUIRED_INTERPRETER}} ${SCRIPT_${VAR}})
      endif()
    endif()
  endmacro()

  if(NOT DEFINED PROG_PATH_SUBDIR)
    set(PROG_PATH_SUBDIR "${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}")
  endif()
  if(DEFINED SUBDIR)
    list(APPEND PATHS ${PROG_PATH_SUBDIR})
  endif()
  if("${PROG_PATH_SUBDIR}" MATCHES [[^(.*)[/\\]$]])
    # remove trailing slash, which may turn into a trailing `\` which CMake _does not like_
    set(PROG_PATH_SUBDIR "${CMAKE_MATCH_1}")
  endif()

  do_find()
  if(NOT ${VAR})
    if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows" AND NOT _vfa_SUPPORTED)
      set(EXAMPLE ".")
      if(DEFINED BREW_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        set(EXAMPLE ":\n    brew install ${BREW_PACKAGE_NAME}")
      elseif(DEFINED APT_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        set(EXAMPLE ":\n    sudo apt-get install ${APT_PACKAGE_NAME}")
      endif()
      message(FATAL_ERROR "Could not find ${PROGNAME}. Please install it via your package manager${EXAMPLE}")
    endif()

    if(DEFINED SOURCEFORGE_ARGS)
      # Locally change editable to suppress re-extraction each time
      set(_VCPKG_EDITABLE 1)
      vcpkg_from_sourceforge(OUT_SOURCE_PATH SFPATH ${SOURCEFORGE_ARGS})
      unset(_VCPKG_EDITABLE)
    else()
      vcpkg_download_distfile(ARCHIVE_PATH
          URLS ${URL}
          SHA512 ${HASH}
          FILENAME ${ARCHIVE}
      )

      file(MAKE_DIRECTORY ${PROG_PATH_SUBDIR})
      if(DEFINED NOEXTRACT)
        if(DEFINED _vfa_RENAME)
          file(INSTALL ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR} RENAME ${_vfa_RENAME} FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
        else()
          file(COPY ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR} FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
        endif()
      else()
        get_filename_component(ARCHIVE_EXTENSION ${ARCHIVE} LAST_EXT)
        string(TOLOWER "${ARCHIVE_EXTENSION}" ARCHIVE_EXTENSION)
        if(ARCHIVE_EXTENSION STREQUAL ".msi")
          file(TO_NATIVE_PATH "${ARCHIVE_PATH}" ARCHIVE_NATIVE_PATH)
          file(TO_NATIVE_PATH "${PROG_PATH_SUBDIR}" DESTINATION_NATIVE_PATH)
          vcpkg_execute_in_download_mode(
            COMMAND msiexec /a ${ARCHIVE_NATIVE_PATH} /qn TARGETDIR=${DESTINATION_NATIVE_PATH}
            WORKING_DIRECTORY ${DOWNLOADS}
          )
        elseif("${ARCHIVE_PATH}" MATCHES ".7z.exe$")
          vcpkg_find_acquire_program(7Z)
          vcpkg_execute_in_download_mode(
            COMMAND ${7Z} x "${ARCHIVE_PATH}" "-o${PROG_PATH_SUBDIR}" -y -bso0 -bsp0
            WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
          )
        else()
          vcpkg_execute_in_download_mode(
            COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
            WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
          )
        endif()
      endif()
    endif()

    if(DEFINED POST_INSTALL_COMMAND)
      vcpkg_execute_required_process(
        ALLOW_IN_DOWNLOAD_MODE
        COMMAND ${POST_INSTALL_COMMAND}
        WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
        LOGNAME ${VAR}-tool-post-install
      )
    endif()
    unset(${VAR} CACHE)
    do_find()
    if(NOT ${VAR})
        message(FATAL_ERROR "Unable to find ${VAR}")
    endif()
  endif()

  set(${VAR} "${${VAR}}" PARENT_SCOPE)
endfunction()
