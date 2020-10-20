## # vcpkg_acquire_msys
##
## Download and prepare an MSYS2 instance.
##
## ## Usage
## ```cmake
## vcpkg_acquire_msys(<MSYS_ROOT_VAR>
##     PACKAGES <package>...
##     [NO_DEFAULT_PACKAGES]
##     [DIRECT_PACKAGES <URL> <SHA512> <URL> <SHA512> ...]
## )
## ```
##
## ## Parameters
## ### MSYS_ROOT_VAR
## An out-variable that will be set to the path to MSYS2.
##
## ### PACKAGES
## A list of packages to acquire in msys.
##
## To ensure a package is available: `vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.16)`
##
## ### NO_DEFAULT_PACKAGES
## Exclude the normal base packages.
##
## The list of base packages includes: bash, coreutils, sed, grep, gawk, diffutils, make, and pkg-config
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
  cmake_parse_arguments(_am "NO_DEFAULT_PACKAGES" "" "PACKAGES;DIRECT_PACKAGES" ${ARGN})

  set(TOTAL_HASH 0)
  set(ARCHIVES)

  set(PACKAGES ${_am_PACKAGES})

  if(NOT _am_NO_DEFAULT_PACKAGES)
    list(APPEND PACKAGES bash coreutils sed grep gawk diffutils make pkg-config)
  endif()

  macro(msys_package_download URL SHA FILENAME)
    set(URLS "${URL}")
    # Mirror list from https://github.com/msys2/MSYS2-packages/blob/master/pacman-mirrors/mirrorlist.msys
    # Sourceforge is not used because it does not keep older package versions
    set(MIRRORS
      "https://www2.futureware.at/~nickoe/msys2-mirror/"
      "https://mirror.yandex.ru/mirrors/msys2/"
      "https://mirrors.tuna.tsinghua.edu.cn/msys2/"
      "https://mirrors.ustc.edu.cn/msys2/"
      "https://mirror.bit.edu.cn/msys2/"
      "https://mirror.selfnet.de/msys2/"
      "https://mirrors.sjtug.sjtu.edu.cn/msys2/"
    )

    foreach(MIRROR IN LISTS MIRRORS)
      string(REPLACE "https://repo.msys2.org/" "${MIRROR}" MIRROR_URL "${URL}")
      list(APPEND URLS "${MIRROR_URL}")
    endforeach()
    vcpkg_download_distfile(MSYS_ARCHIVE
      URLS ${URLS}
      SHA512 "${SHA}"
      FILENAME "msys-${FILENAME}"
      QUIET
    )
    string(APPEND TOTAL_HASH "${SHA}")
    list(APPEND ARCHIVES "${MSYS_ARCHIVE}")
  endmacro()

  macro(msys_package)
    cmake_parse_arguments(p "ZST;ANY" "URL;NAME;SHA512;VERSION;REPO" "DEPS" ${ARGN})
    if(p_URL AND NOT p_NAME)
      if(NOT p_URL MATCHES "^https://repo\\.msys2\\.org/.*/(([^-]+(-[^0-9][^-]*)*)-.+\\.pkg\\.tar\\.(xz|zst))\$")
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
      msys_package_download("${p_URL}" "${p_SHA512}" "${FILENAME}")
    endif()
  endmacro()

  unset(N)
  foreach(P IN LISTS _am_DIRECT_PACKAGES)
    if(NOT DEFINED N)
      set(N "${P}")
    else()
      get_filename_component(FILENAME "${N}" NAME)
      msys_package_download("${N}" "${P}" "${FILENAME}")
      unset(N)
    endif()
  endforeach()
  if(DEFINED N)
    message(FATAL_ERROR "vcpkg_acquire_msys(... DIRECT_PACKAGES ...) requires exactly pairs of URL/SHA512")
  endif()

  # To add new entries, use https://packages.msys2.org/package/$PACKAGE?repo=msys
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
    URL "https://repo.msys2.org/msys/x86_64/bash-4.4.023-2-x86_64.pkg.tar.xz"
    SHA512 1cf2a07022113010e00e150e7004732013a793d49e7a6ac7c2be27a0b2c0ce3366150584b9974e30df042f8876a84d6a77c1a46f0607e38ebe18f8a25f51c32d
    DEPS msys2-runtime
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/autoconf-2.69-5-any.pkg.tar.xz"
    SHA512 66b9c97bd3d1dfe2a2ab576235b6b8c204a9e4c099ba14cf5d0139e564bba1e735e3b1083354b4cac8c6c42233cbdd5e1e277e32cadfe24017b94d2fbdeb5617
    DEPS m4
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/diffutils-3.7-1-x86_64.pkg.tar.xz"
    SHA512 0c39837a26b2111bb6310cdfe0bc14656e3d57456ad8023f59c9386634a8f1f236915c79a57348b64c508897c73ed88d8abce2b9ac512a427e9a3956939f2040
    DEPS msys2-runtime
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/binutils-2.34-4-x86_64.pkg.tar.zst"
    SHA512 5271288d11489879082bc1f2298bb8bedbcfcf6ee19f8a9b3b552b6a4395543d9385bb833e3c32b1560bff1b411d2be503e2c12a7201bf37b85cfacc5f5baba3
    DEPS libiconv libintl
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/libtool-2.4.6-9-x86_64.pkg.tar.xz"
    SHA512 b309799e5a9d248ef66eaf11a0bd21bf4e8b9bd5c677c627ec83fa760ce9f0b54ddf1b62cbb436e641fbbde71e3b61cb71ff541d866f8ca7717a3a0dbeb00ebf
    DEPS grep sed coreutils
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/coreutils-8.32-1-x86_64.pkg.tar.xz"
    SHA512 1a2ae4f296954421ce36f764b9b1c77ca72fc8583c46060b817677d0ad6adc7d7e3c2bbe1ae0179afd116a3d62f28e59eae2f7c84c1c8ffb7d22d2f2b40c0cdc
    DEPS libiconv libintl gmp
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/grep-3.0-2-x86_64.pkg.tar.xz"
    SHA512 c784d5f8a929ae251f2ffaccf7ab0b3936ae9f012041e8f074826dd6077ad0a859abba19feade1e71b3289cc640626dfe827afe91c272b38a1808f228f2fdd00
    DEPS libiconv libintl libpcre
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/sed-4.8-1-x86_64.pkg.tar.xz"
    SHA512 b6e7ed0af9e04aba4992ee26d8616f7ac675c8137bb28558c049d50709afb571b33695ce21d01e5b7fe8e188c008dd2e8cbafc72a7e2a919c2d678506095132b
    DEPS libintl
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/libpcre-8.44-1-x86_64.pkg.tar.xz"
    SHA512 e9e56386fc5cca0f3c36cee21eda91300d9a13a962ec2f52eeea00f131915daea1cfeb0e1b30704bf3cc4357d941d356e0d72192bab3006c2548e18cd96dad77
    DEPS gcc-libs
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/m4-1.4.18-2-x86_64.pkg.tar.xz"
    SHA512 061e9243c1e013aa093546e3872984ad47b7fc9d64d4c39dcce62e750ed632645df00be3fe382a2f55f3bf623dd0d649e2092be23e8f22f921f582e41893e36a
    DEPS msys2-runtime
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/automake-wrapper-11-1-any.pkg.tar.xz"
    SHA512 0fcfc80c31fd0bda5a46c55e9100a86d2fc788a92c7e2ca4fd281e551375c62eb5b9cc9ad9338bb44a815bf0b1d1b60b882c8e68ca3ea529b442f2d03d1d3e1f
    DEPS gawk
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/gawk-5.1.0-1-x86_64.pkg.tar.xz"
    SHA512 4e2be747b184f27945df6fb37d52d56fd8117d2fe4b289370bcdb5b15a4cf90cbeaea98cf9e64bcbfa2c13db50d8bd14cbd719c5f31b420842da903006dbc959
    DEPS libintl libreadline mpfr
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/mpfr-4.1.0-1-x86_64.pkg.tar.zst"
    SHA512 d64fa60e188124591d41fc097d7eb51d7ea4940bac05cdcf5eafde951ed1eaa174468f5ede03e61106e1633e3428964b34c96de76321ed8853b398fbe8c4d072
    DEPS gmp gcc-libs
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/gmp-6.2.0-1-x86_64.pkg.tar.xz"
    SHA512 1389a443e775bb255d905665dd577bef7ed71d51a8c24d118097f8119c08c4dfe67505e88ddd1e9a3764dd1d50ed8b84fa34abefa797d257e90586f0cbf54de8
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/libreadline-8.0.004-1-x86_64.pkg.tar.xz"
    SHA512 42760bddedccc8d93507c1e3a7a81595dc6392b5e4319d24a85275eb04c30eb79078e4247eb2cdd00ff3884d932639130c89bf1b559310a17fa4858062491f97
    DEPS ncurses
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/ncurses-6.2-1-x86_64.pkg.tar.xz"
    SHA512 d4dc566d3dbd32e7646e328cb350689ede7eaa7008c8ed971072f8869a2986fe3935e7df1700851b52716af7ef20c49f9e6628d3163a5e9208a8872b5014eaea
    DEPS msys2-runtime
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/automake1.16-1.16.2-1-any.pkg.tar.zst"
    SHA512 568d1250a31a53452e029d1c236da66d67fffa786a8713128027d33a6a9408cda6e493e9c1555a816efee6245b05a1ef8f9ce3482c39de71356c2e983d926bf7
    DEPS perl
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/automake1.15-1.15.1-1-any.pkg.tar.xz"
    SHA512 d5bb245ab1bb6b57c40ef97755bfb0919dcceb0eccc33e848809922bf6b032f9e4eb36d89aedf41542051277d92238bd48a74115867db0bbc1e1db1c975cc72c
    DEPS perl
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/perl-5.32.0-1-x86_64.pkg.tar.zst"
    SHA512 8acc6c4901bd2e24faf1951084d70029847f05e870826e07b8d9a5d90144f4aa0ab6e568e77c28c36650f016ee75ce78b0356c75673b212c992401f7f1543dd8
    DEPS libcrypt
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/libcrypt-2.1-2-x86_64.pkg.tar.xz"
    SHA512 59a13f79f560934f880d68209a58a3c39ee4a1d24500035bde90d7a6f6ab0d4f72fe14edea6f19a8eb54d4d53b0b6ad4589b388f1521a07ab24a0f8307619cab
    DEPS gcc-libs
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/pkg-config-0.29.2-1-x86_64.pkg.tar.xz"
    SHA512 f1d70f0b4ebcfeb3fa2156a7a4f7b0b404795853e05361de14054dc6658a6154915bb982626cbfe76bef0828325f993f30da6817361ca8d7ea440a40023fa864
    DEPS libiconv
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/make-4.3-1-x86_64.pkg.tar.xz"
    SHA512 7306dec7859edc27d70a24ab4b396728481484a426c5aa2f7e9fed2635b3b25548b05b7d37a161a86a8edaa5922948bee8c99b1e8a078606e69ca48a433fe321
    DEPS libintl msys2-runtime
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/gettext-0.19.8.1-1-x86_64.pkg.tar.xz"
    SHA512 c8c42d084c297746548963f7ec7a7df46241886f3e637e779811ee4a8fee6058f892082bb2658f6777cbffba2de4bcdfd68e846ba63c6a6552c9efb0c8c1de50
    DEPS libintl libgettextpo libasprintf
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/libgettextpo-0.19.8.1-1-x86_64.pkg.tar.xz"
    SHA512 480b782a79b0ce71ed9939ae3a6821fc2f5a63358733965c62cee027d0e6c88e255df1d62379ee47f5a7f8ffe163e554e318dba22c67dc67469b10aa3248edf7
    DEPS gcc-libs
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/libasprintf-0.19.8.1-1-x86_64.pkg.tar.xz"
    SHA512 a2e8027b9bbee20f8cf60851130ca2af436641b1fb66054f8deba118da7ebecb1cd188224dcf08e4c5b7cde85b412efab058afef2358e843c9de8eb128ca448c
    DEPS gcc-libs
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/libintl-0.19.8.1-1-x86_64.pkg.tar.xz"
    SHA512 4e54c252b828c862f376d8f5a2410ee623a43d70cbb07d0b8ac20c25096f59fb3ae8dcd011d1792bec76f0b0b9411d0e184ee23707995761dc50eb76f9fc6b92
    DEPS libiconv
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/libiconv-1.16-1-x86_64.pkg.tar.xz"
    SHA512 6f9b778d449410273a50cdd1af737cdcb8890a5536d78211477eed7382340253c7aadfb04977f1038ae4f4cef5a641f1acfda26fd06323d0b196a3e6da7fd425
    DEPS gcc-libs
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/gcc-libs-9.3.0-1-x86_64.pkg.tar.xz"
    SHA512 2816afbf45aa0ff47f94a623ad083d9421bca5284dc55683c2f1bc09ea0eadfe720afb75aafef60c2ff6384d051c4fbe2a744bb16a20acf34c04dc59b17c3d8c
    DEPS msys2-runtime
  )
  msys_package(
    URL "https://repo.msys2.org/msys/x86_64/msys2-runtime-3.1.6-3-x86_64.pkg.tar.xz"
    SHA512 f094a7f4926195ef7ba015f0c5c56587b1faa94d85530f07aaaa5557a1494c3bd75257d4687c8401cbf1328d23e5586a92b05f0a872caebb1a7e941a07829776
  )

  if(PACKAGES)
    message(FATAL_ERROR "Unknown packages were required for vcpkg_acquire_msys(${_am_PACKAGES}): ${PACKAGES}\nThis can be resolved by explicitly passing URL/SHA pairs to DIRECT_PACKAGES.")
  endif()

  string(SHA512 TOTAL_HASH "${TOTAL_HASH}")
  string(SUBSTRING "${TOTAL_HASH}" 0 16 TOTAL_HASH)
  set(PATH_TO_ROOT ${DOWNLOADS}/tools/msys2/${TOTAL_HASH})
  if(NOT EXISTS "${PATH_TO_ROOT}")
    file(REMOVE_RECURSE ${PATH_TO_ROOT}.tmp)
    file(MAKE_DIRECTORY ${PATH_TO_ROOT}.tmp/tmp)
    set(I 0)
    foreach(ARCHIVE IN LISTS ARCHIVES)
      vcpkg_execute_required_process(
        ALLOW_IN_DOWNLOAD_MODE
        COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE}
        LOGNAME msys-${TARGET_TRIPLET}-${I}
        WORKING_DIRECTORY ${PATH_TO_ROOT}.tmp
      )
      math(EXPR I "${I} + 1")
    endforeach()
    file(RENAME ${PATH_TO_ROOT}.tmp ${PATH_TO_ROOT})
  endif()
  message(STATUS "Using msys root at ${DOWNLOADS}/tools/msys2/${TOTAL_HASH}")
  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
