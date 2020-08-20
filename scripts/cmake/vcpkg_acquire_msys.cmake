## # vcpkg_acquire_msys
##
## Download and prepare an MSYS2 instance.
##
## ## Usage
## ```cmake
## vcpkg_acquire_msys(<MSYS_ROOT_VAR> PACKAGES <package>... [DIRECT_PACKAGES <URL1> <SHA512> <URL2> <SHA512> ...])
## ```
##
## ## Parameters
## ### MSYS_ROOT_VAR
## An out-variable that will be set to the path to MSYS2.
##
## ### PACKAGES
## A list of packages to acquire in msys.
##
## To ensure a package is available: `vcpkg_acquire_msys(MSYS_ROOT PACKAGES bash make automake1.16)`
##
## ### DIRECT_PACKAGES
## A list of URL/SHA512 pairs to acquire in msys.
##
## This parameter can be used by a port to privately extend the list of msys packages to be acquired.
## The URLs can be found on the msys2 website[1] and should be a direct archive link:
##
##     https://repo.msys2.org/mingw/i686/mingw-w64-i686-gettext-0.19.8.1-9-any.pkg.tar.zst
##
## [1] https://packages.msys2.org/search
##
## ## Notes
## A call to `vcpkg_acquire_msys` will usually be followed by a call to `bash.exe`:
## ```cmake
## vcpkg_acquire_msys(MSYS_ROOT PACKAGES bash)
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
  cmake_parse_arguments(_am "" "" "PACKAGES;DIRECT_PACKAGES" ${ARGN})

  set(TOTAL_HASH 0)
  set(ARCHIVES)

  set(PACKAGES ${_am_PACKAGES})

  macro(msys_package)
    cmake_parse_arguments(p "ZST;ANY" "URL;NAME;SHA512;VERSION;REPO" "DEPS" ${ARGN})
    if(p_URL AND NOT p_NAME)
      if(NOT p_URL MATCHES "^https://repo\\.msys2\\.org/.*/(([^\\.]+)-.+\\.pkg\\.tar\\.(xz|zst))\$")
        message(FATAL_ERROR "Regex does not match supplied URL to vcpkg_acquire_msys: ${p_URL}")
      endif()
      set(FILENAME "${CMAKE_MATCH_1}")
      set(p_NAME "${CMAKE_MATCH_2}")
    else()
      if(p_ZST)
        set(EXT zst)
      else()
        set(EXT xz)
      endif()
      if(p_ANY)
        set(ARCH any)
      else()
        set(ARCH x86_64)
      endif()
      if(NOT p_REPO)
        set(p_REPO msys/x86_64)
      endif()
      set(FILENAME "${p_NAME}-${p_VERSION}-${ARCH}.pkg.tar.${EXT}")
      set(p_URL "https://repo.msys2.org/${p_REPO}/${FILENAME}")
    endif()
    if("${p_NAME}" IN_LIST PACKAGES)
      list(REMOVE_ITEM PACKAGES "${p_NAME}")
      list(APPEND PACKAGES ${p_DEPS})
      vcpkg_download_distfile(MSYS_ARCHIVE
        URLS "${p_URL}"
        SHA512 "${p_SHA512}"
        FILENAME "msys-${FILENAME}"
        QUIET
      )
      string(APPEND TOTAL_HASH "${p_SHA512}")
      list(APPEND ARCHIVES "${MSYS_ARCHIVE}")
    endif()
  endmacro()

  unset(N)
  foreach(P IN LISTS _am_DIRECT_PACKAGES)
    if(NOT DEFINED N)
      set(N "${P}")
    else()
      get_filename_component(FILENAME "${N}" NAME)
      vcpkg_download_distfile(MSYS_ARCHIVE
        URLS "${N}"
        SHA512 "${P}"
        FILENAME "msys-${FILENAME}"
        QUIET
      )
      string(APPEND TOTAL_HASH "${P}")
      list(APPEND ARCHIVES "${MSYS_ARCHIVE}")
      unset(N)
    endif()
  endforeach()
  if(DEFINED N)
    message(FATAL_ERROR "vcpkg_acquire_msys(... DIRECT_PACKAGES ...) requires exactly pairs of URL/SHA512")
  endif()

  # To add new entries, use https://packages.msys2.org/package/$PACKAGE?repo=msys
  msys_package(
    URL "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gettext-0.19.8.1-9-any.pkg.tar.zst"
    SHA512 c632877544183def8b19659421c5511b87f8339596e1606bd47608277a0bf427d370aba1732915c2832c91f6d525261623401f145b951ff3015f79ac54179c19
    DEPS mingw-w64-i686-libiconv mingw-w64-i686-gcc-libs
  )
  msys_package(
    URL "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libiconv-1.16-1-any.pkg.tar.xz"
    SHA512 ba236e1efc990cb91d459f938be6ca6fc2211be95e888d73f8de301bce55d586f9d2b6be55dacb975ec1afa7952b510906284eff70210238919e341dffbdbeb8
  )
  msys_package(
    URL "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-libs-10.2.0-1-any.pkg.tar.zst"
    SHA512 113d8b3b155ea537be8b99688d454f781d70c67c810c2643bc02b83b332d99bfbf3a7fcada6b927fda67ef02cf968d4fdf930466c5909c4338bda64f1f3f483e
    DEPS mingw-w64-i686-libwinpthread-git mingw-w64-i686-mpc
  )
  msys_package(
    URL "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libwinpthread-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst"
    SHA512 2c3d9e6b2eee6a4c16fd69ddfadb6e2dc7f31156627d85845c523ac85e5c585d4cfa978659b1fe2ec823d44ef57bc2b92a6127618ff1a8d7505458b794f3f01c
  )
  msys_package(
    URL "https://repo.msys2.org/mingw/i686/mingw-w64-i686-mpc-1.1.0-1-any.pkg.tar.xz"
    SHA512 d236b815ec3cf569d24d96a386eca9f69a2b1e8af18e96c3f1e5a4d68a3598d32768c7fb3c92207ecffe531259822c1a421350949f2ffabd8ee813654f1af864
    DEPS mingw-w64-i686-mpfr
  )
  msys_package(
    URL "https://repo.msys2.org/mingw/i686/mingw-w64-i686-mpfr-4.1.0-2-any.pkg.tar.zst"
    SHA512 caac5cb73395082b479597a73c7398bf83009dbc0051755ef15157dc34996e156d4ed7881ef703f9e92861cfcad000888c4c32e4bf38b2596c415a19aafcf893
    DEPS mingw-w64-i686-gmp
  )
  msys_package(
    URL "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gmp-6.2.0-1-any.pkg.tar.xz"
    SHA512 37747f3f373ebff1a493f5dec099f8cd6d5abdc2254d9cd68a103ad7ba44a81a9a97ccaba76eaee427b4d67b2becb655ee2c379c2e563c8051b6708431e3c588
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/unzip-6.0-2-x86_64.pkg.tar.xz"
    SHA512 b8a1e0ce6deff26939cb46267f80ada0a623b7d782e80873cea3d388b4dc3a1053b14d7565b31f70bc904bf66f66ab58ccc1cd6bfa677065de1f279dd331afb9
    DEPS libbz2
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/libbz2-1.0.8-2-x86_64.pkg.tar.xz"
    SHA512 d128bd1792d0f5750e6a63a24db86a791e7ee457db8c0bef68d217099be4a6eef27c85caf6ad09b0bcd5b3cdac6fc0a2b9842cc58d381a4035505906cc4803ec
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/patch-2.7.6-1-x86_64.pkg.tar.xz"
    SHA512 04d06b9d5479f129f56e8290e0afe25217ffa457ec7bed3e576df08d4a85effd80d6e0ad82bd7541043100799b608a64da3c8f535f8ea173d326da6194902e8c
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/gzip-1.10-1-x86_64.pkg.tar.xz"
    SHA512 2d0a60f2c384e3b9e2bed2212867c85333545e51ee0f583a33914e488e43c265ed0017cd4430a6e3dafdca99c0414b3756a4b9cc92a6f04d5566eff8b68def75
    DEPS msys2-runtime
  )
  msys_package(
    NAME bash
    VERSION 4.4.023-2
    DEPS msys2-runtime
    SHA512 1cf2a07022113010e00e150e7004732013a793d49e7a6ac7c2be27a0b2c0ce3366150584b9974e30df042f8876a84d6a77c1a46f0607e38ebe18f8a25f51c32d
  )
  msys_package(
    NAME autoconf
    VERSION 2.69-5
    DEPS m4
    SHA512 66b9c97bd3d1dfe2a2ab576235b6b8c204a9e4c099ba14cf5d0139e564bba1e735e3b1083354b4cac8c6c42233cbdd5e1e277e32cadfe24017b94d2fbdeb5617
    ANY
  )
  msys_package(
    NAME diffutils
    VERSION 3.7-1
    DEPS msys2-runtime
    SHA512 0c39837a26b2111bb6310cdfe0bc14656e3d57456ad8023f59c9386634a8f1f236915c79a57348b64c508897c73ed88d8abce2b9ac512a427e9a3956939f2040
  )
  msys_package(
    NAME binutils
    VERSION 2.34-4
    DEPS libiconv libintl
    SHA512 5271288d11489879082bc1f2298bb8bedbcfcf6ee19f8a9b3b552b6a4395543d9385bb833e3c32b1560bff1b411d2be503e2c12a7201bf37b85cfacc5f5baba3
    ZST
  )
  msys_package(
    NAME libtool
    VERSION 2.4.6-9
    DEPS grep sed coreutils
    SHA512 b309799e5a9d248ef66eaf11a0bd21bf4e8b9bd5c677c627ec83fa760ce9f0b54ddf1b62cbb436e641fbbde71e3b61cb71ff541d866f8ca7717a3a0dbeb00ebf
  )
  msys_package(
    NAME coreutils
    VERSION 8.32-1
    DEPS libiconv libintl gmp
    SHA512 1a2ae4f296954421ce36f764b9b1c77ca72fc8583c46060b817677d0ad6adc7d7e3c2bbe1ae0179afd116a3d62f28e59eae2f7c84c1c8ffb7d22d2f2b40c0cdc
  )
  msys_package(
    NAME grep
    VERSION 3.0-2
    DEPS libiconv libintl libpcre
    SHA512 c784d5f8a929ae251f2ffaccf7ab0b3936ae9f012041e8f074826dd6077ad0a859abba19feade1e71b3289cc640626dfe827afe91c272b38a1808f228f2fdd00
  )
  msys_package(
    NAME sed
    VERSION 4.8-1
    DEPS libintl
    SHA512 b6e7ed0af9e04aba4992ee26d8616f7ac675c8137bb28558c049d50709afb571b33695ce21d01e5b7fe8e188c008dd2e8cbafc72a7e2a919c2d678506095132b
  )
  msys_package(
    NAME libpcre
    VERSION 8.44-1
    DEPS gcc-libs
    SHA512 e9e56386fc5cca0f3c36cee21eda91300d9a13a962ec2f52eeea00f131915daea1cfeb0e1b30704bf3cc4357d941d356e0d72192bab3006c2548e18cd96dad77
  )
  msys_package(
    NAME m4
    VERSION 1.4.18-2
    DEPS msys2-runtime
    SHA512 061e9243c1e013aa093546e3872984ad47b7fc9d64d4c39dcce62e750ed632645df00be3fe382a2f55f3bf623dd0d649e2092be23e8f22f921f582e41893e36a
  )
  msys_package(
    NAME automake-wrapper
    DEPS gawk
    VERSION 11-1
    SHA512 0fcfc80c31fd0bda5a46c55e9100a86d2fc788a92c7e2ca4fd281e551375c62eb5b9cc9ad9338bb44a815bf0b1d1b60b882c8e68ca3ea529b442f2d03d1d3e1f
    ANY
  )
  msys_package(
    NAME gawk
    DEPS libintl libreadline mpfr
    VERSION 5.1.0-1
    SHA512 4e2be747b184f27945df6fb37d52d56fd8117d2fe4b289370bcdb5b15a4cf90cbeaea98cf9e64bcbfa2c13db50d8bd14cbd719c5f31b420842da903006dbc959
  )
  msys_package(
    NAME mpfr
    DEPS gmp gcc-libs
    VERSION 4.1.0-1
    SHA512 d64fa60e188124591d41fc097d7eb51d7ea4940bac05cdcf5eafde951ed1eaa174468f5ede03e61106e1633e3428964b34c96de76321ed8853b398fbe8c4d072
    ZST
  )
  msys_package(
    NAME gmp
    VERSION 6.2.0-1
    SHA512 1389a443e775bb255d905665dd577bef7ed71d51a8c24d118097f8119c08c4dfe67505e88ddd1e9a3764dd1d50ed8b84fa34abefa797d257e90586f0cbf54de8
  )
  msys_package(
    NAME libreadline
    DEPS ncurses
    VERSION 8.0.004-1
    SHA512 42760bddedccc8d93507c1e3a7a81595dc6392b5e4319d24a85275eb04c30eb79078e4247eb2cdd00ff3884d932639130c89bf1b559310a17fa4858062491f97
  )
  msys_package(
    NAME ncurses
    VERSION 6.2-1
    DEPS msys2-runtime
    SHA512 d4dc566d3dbd32e7646e328cb350689ede7eaa7008c8ed971072f8869a2986fe3935e7df1700851b52716af7ef20c49f9e6628d3163a5e9208a8872b5014eaea
  )
  msys_package(
    NAME gcc-libs
    VERSION 9.3.0-1
    DEPS msys2-runtime
    SHA512 2816afbf45aa0ff47f94a623ad083d9421bca5284dc55683c2f1bc09ea0eadfe720afb75aafef60c2ff6384d051c4fbe2a744bb16a20acf34c04dc59b17c3d8c
  )
  msys_package(
    NAME automake1.16
    VERSION 1.16.2-1
    DEPS perl
    SHA512 568d1250a31a53452e029d1c236da66d67fffa786a8713128027d33a6a9408cda6e493e9c1555a816efee6245b05a1ef8f9ce3482c39de71356c2e983d926bf7
    ZST
    ANY
  )
  msys_package(
    NAME pkg-config
    VERSION 0.29.2-1
    SHA512 f1d70f0b4ebcfeb3fa2156a7a4f7b0b404795853e05361de14054dc6658a6154915bb982626cbfe76bef0828325f993f30da6817361ca8d7ea440a40023fa864
    DEPS libiconv
  )
  msys_package(
    NAME make
    VERSION 4.3-1
    DEPS libintl msys2-runtime
    SHA512 7306dec7859edc27d70a24ab4b396728481484a426c5aa2f7e9fed2635b3b25548b05b7d37a161a86a8edaa5922948bee8c99b1e8a078606e69ca48a433fe321
  )
  msys_package(
    NAME perl
    DEPS libcrypt
    VERSION 5.32.0-1
    SHA512 8acc6c4901bd2e24faf1951084d70029847f05e870826e07b8d9a5d90144f4aa0ab6e568e77c28c36650f016ee75ce78b0356c75673b212c992401f7f1543dd8
    ZST
  )
  msys_package(
    NAME libcrypt
    VERSION 2.1-2
    SHA512 59a13f79f560934f880d68209a58a3c39ee4a1d24500035bde90d7a6f6ab0d4f72fe14edea6f19a8eb54d4d53b0b6ad4589b388f1521a07ab24a0f8307619cab
  )
  msys_package(
    NAME libintl
    VERSION 0.19.8.1-1
    DEPS libiconv
    SHA512 4e54c252b828c862f376d8f5a2410ee623a43d70cbb07d0b8ac20c25096f59fb3ae8dcd011d1792bec76f0b0b9411d0e184ee23707995761dc50eb76f9fc6b92
  )
  msys_package(
    NAME libiconv
    VERSION 1.16-1
    SHA512 6f9b778d449410273a50cdd1af737cdcb8890a5536d78211477eed7382340253c7aadfb04977f1038ae4f4cef5a641f1acfda26fd06323d0b196a3e6da7fd425
  )
  msys_package(
    NAME msys2-runtime
    VERSION 3.1.6-3
    SHA512 f094a7f4926195ef7ba015f0c5c56587b1faa94d85530f07aaaa5557a1494c3bd75257d4687c8401cbf1328d23e5586a92b05f0a872caebb1a7e941a07829776
  )

  if(PACKAGES)
    message(FATAL_ERROR "Unknown packages were required for vcpkg_acquire_msys(${_am_PACKAGES}): ${PACKAGES}\nThis can be fixed by adding appropriate entries to ${CMAKE_CURRENT_LIST_FILE}.")
  endif()

  string(SHA512 TOTAL_HASH "${TOTAL_HASH}")
  string(SUBSTRING "${TOTAL_HASH}" 0 16 TOTAL_HASH)
  set(PATH_TO_ROOT ${DOWNLOADS}/tools/msys2/${TOTAL_HASH})
  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
  if(EXISTS "${PATH_TO_ROOT}")
    message(STATUS "Using msys root at ${DOWNLOADS}/tools/msys2/${TOTAL_HASH}")
    return()
  endif()

  file(REMOVE_RECURSE ${PATH_TO_ROOT}.tmp)
  file(MAKE_DIRECTORY ${PATH_TO_ROOT}.tmp/tmp)
  foreach(ARCHIVE IN LISTS ARCHIVES)
    _execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE}
      RESULT_VARIABLE err
      WORKING_DIRECTORY ${PATH_TO_ROOT}.tmp
    )
    if(err)
      message(FATAL_ERROR "Failure while unpacking ${ARCHIVE} for vcpkg_acquire_msys(PACKAGES ${_am_PACKAGES}).")
    endif()
  endforeach()
  file(RENAME ${PATH_TO_ROOT}.tmp ${PATH_TO_ROOT})
  message(STATUS "Using msys root at ${DOWNLOADS}/tools/msys2/${TOTAL_HASH}")
endfunction()
