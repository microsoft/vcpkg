#[===[.md:
# vcpkg_acquire_msys

Download and prepare an MSYS2 instance.

## Usage
```cmake
vcpkg_acquire_msys(<MSYS_ROOT_VAR>
    PACKAGES <package>...
    [NO_DEFAULT_PACKAGES]
    [DIRECT_PACKAGES <URL> <SHA512> <URL> <SHA512> ...]
)
```

## Parameters
### MSYS_ROOT_VAR
An out-variable that will be set to the path to MSYS2.

### PACKAGES
A list of packages to acquire in msys.

To ensure a package is available: `vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.16)`

### NO_DEFAULT_PACKAGES
Exclude the normal base packages.

The list of base packages includes: bash, coreutils, sed, grep, gawk, diffutils, make, and pkg-config

### DIRECT_PACKAGES
A list of URL/SHA512 pairs to acquire in msys.

This parameter can be used by a port to privately extend the list of msys packages to be acquired.
The URLs can be found on the msys2 website[1] and should be a direct archive link:

    https://repo.msys2.org/mingw/i686/mingw-w64-i686-gettext-0.19.8.1-9-any.pkg.tar.zst

[1] https://packages.msys2.org/search

## Notes
A call to `vcpkg_acquire_msys` will usually be followed by a call to `bash.exe`:
```cmake
vcpkg_acquire_msys(MSYS_ROOT)
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME build-${TARGET_TRIPLET}-rel
)
```

## Examples

* [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
* [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)
* [libvpx](https://github.com/Microsoft/vcpkg/blob/master/ports/libvpx/portfile.cmake)
#]===]

function(vcpkg_acquire_msys PATH_TO_ROOT_OUT)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _am "NO_DEFAULT_PACKAGES" "" "PACKAGES;DIRECT_PACKAGES")

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
        URL "https://repo.msys2.org/msys/x86_64/texinfo-6.7-1-x86_64.pkg.tar.xz"
        SHA512 d352e06c916ab5d8e34722a8d8bb93ff975525349c9bdf8206e472d93b25158134f97ba5101ffd0d32cd8d88522c0935d3c83847e759aa5376a2276aa2a392b3
        DEPS bash perl
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
        URL "https://repo.msys2.org/msys/x86_64/autoconf-archive-2019.01.06-1-any.pkg.tar.xz"
        SHA512 77540d3d3644d94a52ade1f5db27b7b4b5910bbcd6995195d511378ca6d394a1dd8d606d57161c744699e6c63c5e55dfe6e8664d032cc8c650af9fdbb2db08b0
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
        DEPS grep sed coreutils file findutils
    )
    msys_package(
        URL "https://repo.msys2.org/msys/x86_64/file-5.39-1-x86_64.pkg.tar.zst"
        SHA512 be51dd0f6143a2f34f2a3e7d412866eb12511f25daaf3a5478240537733a67d7797a3a55a8893e5638589c06bca5af20aed5ded7db0bf19fbf52b30fae08cadd
        DEPS gcc-libs zlib libbz2
    )
    msys_package(
        URL "https://repo.msys2.org/msys/x86_64/zlib-1.2.11-1-x86_64.pkg.tar.xz"
        SHA512 b607da40d3388b440f2a09e154f21966cd55ad77e02d47805f78a9dee5de40226225bf0b8335fdfd4b83f25ead3098e9cb974d4f202f28827f8468e30e3b790d
        DEPS gcc-libs
    )
    msys_package(
        URL "https://repo.msys2.org/msys/x86_64/bzip2-1.0.8-2-x86_64.pkg.tar.xz"
        SHA512 336f5b59eb9cf4e93b537a212509d84f72cd9b8a97bf8ac0596eff298f3c0979bdea6c605244d5913670b9d20b017e5ee327f1e606f546a88e177a03c589a636
        DEPS gcc-libs
    )
    msys_package(
        URL "https://repo.msys2.org/msys/x86_64/libbz2-1.0.8-2-x86_64.pkg.tar.xz"
        SHA512 d128bd1792d0f5750e6a63a24db86a791e7ee457db8c0bef68d217099be4a6eef27c85caf6ad09b0bcd5b3cdac6fc0a2b9842cc58d381a4035505906cc4803ec
        DEPS gcc-libs
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
        URL "https://repo.msys2.org/msys/x86_64/xz-5.2.5-1-x86_64.pkg.tar.xz" # this seems to require immediate updating on version bumps. 
        SHA512 99d092c3398277e47586cead103b41e023e9432911fb7bdeafb967b826f6a57d32e58afc94c8230dad5b5ec2aef4f10d61362a6d9e410a6645cf23f076736bba
        DEPS liblzma libiconv gettext
    )
    msys_package(
        URL "https://repo.msys2.org/msys/x86_64/liblzma-5.2.5-1-x86_64.pkg.tar.xz"
        SHA512 8d5c04354fdc7309e73abce679a4369c0be3dc342de51cef9d2a932b7df6a961c8cb1f7e373b1b8b2be40343a95fbd57ac29ebef63d4a2074be1d865e28ca6ad
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
        URL "https://repo.msys2.org/msys/x86_64/pkg-config-0.29.2-4-x86_64.pkg.tar.zst"
        SHA512 9f72c81d8095ca1c341998bc80788f7ce125770ec4252f1eb6445b9cba74db5614caf9a6cc7c0fcc2ac18d4a0f972c49b9f245c3c9c8e588126be6c72a8c1818
        DEPS libiconv
    )
    msys_package(
        URL "https://repo.msys2.org/msys/x86_64/make-4.3-1-x86_64.pkg.tar.xz"
        SHA512 7306dec7859edc27d70a24ab4b396728481484a426c5aa2f7e9fed2635b3b25548b05b7d37a161a86a8edaa5922948bee8c99b1e8a078606e69ca48a433fe321
        DEPS libintl msys2-runtime
    )
msys_package(
        URL "https://repo.msys2.org/msys/x86_64/gettext-devel-0.19.8.1-1-x86_64.pkg.tar.xz"
        SHA512 648f74c23e4f92145cdd0d45ff5285c2df34e855a9e75e5463dd6646967f8cf34a18ce357c6f498a4680e6d7b84e2d1697ba9deee84da8ea6bb14bbdb594ee22
        DEPS gettext
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
        URL "https://repo.msys2.org/msys/x86_64/findutils-4.7.0-1-x86_64.pkg.tar.xz"
        SHA512 fd09a24562b196ff252f4b5de86ed977280306a8c628792930812f146fcf7355f9d87434bbabe25e6cc17d8bd028f6bc68fc02e5bea83137a49cf5cc6f509e10
        DEPS libintl libiconv
    )
    msys_package(
        URL "https://repo.msys2.org/msys/x86_64/libintl-0.19.8.1-1-x86_64.pkg.tar.xz"
        SHA512 4e54c252b828c862f376d8f5a2410ee623a43d70cbb07d0b8ac20c25096f59fb3ae8dcd011d1792bec76f0b0b9411d0e184ee23707995761dc50eb76f9fc6b92
        DEPS libiconv
    )
    msys_package(
        URL "https://repo.msys2.org/msys/x86_64/libiconv-1.16-2-x86_64.pkg.tar.zst"
        SHA512 3ab569eca9887ef85e7dd5dbca3143d8a60f7103f370a7ecc979a58a56b0c8dcf1f54ac3df4495bc306bd44bf36ee285aaebbb221c4eebfc912cf47d347d45fc
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

    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-python-numpy-1.19.0-1-any.pkg.tar.zst"
        SHA512 15791fff23deda17a4452c9ca3f23210ed77ee20dcdd6e0c31d0e626a63aeb93d15ed814078729101f1cce96129b4b5e3c898396b003d794a52d7169dd027465
        DEPS mingw-w64-x86_64-openblas mingw-w64-x86_64-python
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-openblas-0.3.10-2-any.pkg.tar.zst"
        SHA512 3cf15ef191ceb303a7e40ad98aca94c56211b245617c17682379b5606a1a76e12d04fa1a83c6109e89620200a74917bcd981380c7749dda12fa8e79f0b923877
        DEPS mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libwinpthread
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libgfortran-10.2.0-1-any.pkg.tar.zst"
        SHA512 c2dee2957356fa51aae39d907d0cc07f966028b418f74a1ea7ea551ff001c175d86781f980c0cf994207794322dcd369fa122ab78b6c6d0f0ab01e39a754e780
        DEPS mingw-w64-x86_64-gcc-libs
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-python-3.8.5-1-any.pkg.tar.zst"
        SHA512 49bbcaa9479ff95fd21b473a1bc286886b204ec3e2e0d9466322e96a9ee07ccd8116024b54b967a87e4752057004475cac5060605e87bd5057de45efe5122a25
        DEPS mingw-w64-x86_64-bzip2 mingw-w64-x86_64-expat mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libffi mingw-w64-x86_64-mpdecimal mingw-w64-x86_64-ncurses mingw-w64-x86_64-openssl mingw-w64-x86_64-sqlite3 mingw-w64-x86_64-tcl mingw-w64-x86_64-tk mingw-w64-x86_64-xz mingw-w64-x86_64-zlib
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-bzip2-1.0.8-1-any.pkg.tar.xz"
        SHA512 6e01b26a2144f99ca00406dbce5b8c3e928ec8a3ff77e0b741b26aaf9c927e9bea8cb1b5f38cd59118307e10dd4523a0ea2a1ea61f798f99e6d605ef1d100503
        DEPS mingw-w64-x86_64-gcc-libs
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpdecimal-2.5.0-1-any.pkg.tar.zst"
        SHA512 48130ff676c0235bad4648527021e597ee00aa49a4443740a134005877e2ff2ca27b30a0ac86b923192a65348b36de4e8d3f9c57d76ab42b2e21d1a92dbf7ccf
        DEPS mingw-w64-x86_64-gcc-libs
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-ncurses-6.2-1-any.pkg.tar.xz"
        SHA512 1cbffe0e181a3d4ceaa8f39b2a649584b2c7d689e6a057d85cb9f84edece2cf60eddc220127c7fa4f29e4aa6e8fb4f568ef9d73582d08168607135af977407e0
        DEPS mingw-w64-x86_64-libsystre
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libsystre-1.0.1-4-any.pkg.tar.xz"
        SHA512 6540e896636d00d1ea4782965b3fe4d4ef1e32e689a98d25e2987191295b319eb1de2e56be3a4b524ff94f522a6c3e55f8159c1a6f58c8739e90f8e24e2d40d8
        DEPS mingw-w64-x86_64-libtre
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libtre-git-r128.6fb7206-2-any.pkg.tar.xz"
        NAME mingw-w64-x86_64-libtre
        VERSION git-r128.6fb7206-2
        ANY
        REPO mingw/x86_64
        SHA512 d595dbcf3a3b6ed098e46f370533ab86433efcd6b4d3dcf00bbe944ab8c17db7a20f6535b523da43b061f071a3b8aa651700b443ae14ec752ae87500ccc0332d
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gettext
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-openssl-1.1.1.g-1-any.pkg.tar.xz"
        SHA512 81681089a19cae7dbdee1bc9d3148f03458fa7a1d2fd105be39299b3a0c91b34450bcfe2ad86622bc6819da1558d7217deb0807b4a7bed942a9a7a786fcd54a3
        DEPS mingw-w64-x86_64-ca-certificates mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-ca-certificates-20200601-1-any.pkg.tar.zst"
        SHA512 21a81e1529a3ad4f6eceb3b7d4e36400712d3a690d3991131573d4aae8364965757f9b02054d93c853eb75fbb7f6173a278b122450c800b2c9a1e8017dd35e28
        DEPS mingw-w64-x86_64-p11-kit
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-p11-kit-0.23.20-2-any.pkg.tar.xz"
        SHA512 c441c4928465a98aa53917df737b728275bc0f6e9b41e13de7c665a37d2111b46f057bb652a1d5a6c7cdf8a74ea15e365a727671b698f5bbb5a7cfd0b889935e
        DEPS mingw-w64-x86_64-gettext mingw-w64-x86_64-libffi mingw-w64-x86_64-libtasn1
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libtasn1-4.16.0-1-any.pkg.tar.xz"
        SHA512 c450cd49391b46af552a89f2f6e2c21dd5da7d40e7456b380290c514a0f06bcbd63f0f972b3c173c4237bec7b652ff22d2d330e8fdf5c888558380bd2667be64
        DEPS mingw-w64-x86_64-gcc-libs
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-sqlite3-3.33.0-1-any.pkg.tar.zst"
        SHA512 eae319f87c9849049347f132efc2ecc46e9ac1ead55542e31a3ea216932a4fa5c5bae8d468d2f050e1e22068ac9fbe9d8e1aa7612cc0110cafe6605032adeb0f
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-readline mingw-w64-x86_64-tcl
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-readline-8.0.004-1-any.pkg.tar.xz"
        SHA512 e3fb3030a50f677697bec0da39ba2eb979dc28991ad0e29012cbf1bda82723176148510bf924b7fce7a0b79e7b078232d69e07f3fbb7d657b8ee631841730120
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-termcap
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-termcap-1.3.1-6-any.pkg.tar.zst"
        SHA512 602d182ba0f1e20c4c51ae09b327c345bd736e6e4f22cd7d58374ac68c705dd0af97663b9b94d41870457f46bb9110abb29186d182196133618fc460f71d1300
        DEPS mingw-w64-x86_64-gcc-libs
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-tk-8.6.10-1-any.pkg.tar.xz"
        SHA512 3be88b87d5e77a875ea98f0bce4192242e550eeb1b0d44abfee9c8797135a45dd3219b89006de99458dd3f9ae47da77dccc63dab25cea93fbc285af756264eb8
        DEPS mingw-w64-x86_64-tcl
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-tcl-8.6.10-1-any.pkg.tar.xz"
        SHA512 c3f21588e19725598878ef13145fbe7a995c2a0c678ef0a4782e28fd64d65fe3271178369bf0c54e92123eba82f2d3da6ae2fc34acd3b20150d1e173be1c0f8f
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-xz-5.2.5-1-any.pkg.tar.xz"
        SHA512 0e1336a1565cda6e78996d69ba973aaa3522392ab586f70b0b93dbe09be50baf3e14f8ba0afcc665bc885508f1a898b16f206f89eaa3cbc9985afeea6ff1c02b
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gettext
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gettext-0.19.8.1-9-any.pkg.tar.zst"
        SHA512 571a36cf60e40172aaa7a5a40b1db60bbea145d9f399603a625a57ca106679f6feb53fda73d935ce8f0057935cad5b9a8770ae4f065e54e1554a1932b48eec97
        DEPS mingw-w64-x86_64-expat mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libiconv
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libs-10.2.0-1-any.pkg.tar.zst"
        SHA512 d17eff08c83d08ef020d999a2ead0d25036ada1c1bf6ed7c02bad9b56840ee5a3304acd790d86f52b83b09c1e788f0cecdf7254dc6760c3c7e478f65882cd32d
        DEPS mingw-w64-x86_64-gmp mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpc-1.2.0-1-any.pkg.tar.zst"
        SHA512 e2e561ef7c1bd85bbf021ecbe4df1cfd377a5b426ec0091f267111b9f18d476d5f95a40e0ffbd97aee5f331c49dc7a8dfc2111d54cc979643fae30e564d671aa
        DEPS mingw-w64-x86_64-mpfr
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpfr-4.1.0-2-any.pkg.tar.zst"
        SHA512 14739667242b8852f0d26547eb3297899a51fd1edafc7101b4e7489273e1efb9cb8422fc067361e3c3694c2afcc6c49fc89537f9f811ad5b9b595873112ee890
        DEPS mingw-w64-x86_64-gmp
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gmp-6.2.0-1-any.pkg.tar.xz"
        SHA512 0b22b7363e27cec706eb79ee0c45b5fe7088a5ca69e0868e7366481ed2ea9b3f6623d340cebba0b5ed3d79e4dfc7cf15f53530eb260c6d4057bfc3d92eb8c7bc
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-expat-2.2.9-1-any.pkg.tar.xz"
        SHA512 1f747b9c7e6ee680b6d8f76429e81a42e2d4ab72d5d930207c90f4513cca5158c08c8296889fd27fe07a275cdeff5d34b5de0e6d1cd982d2e1d05765d6c8c31a
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libffi-3.3-1-any.pkg.tar.xz"
        SHA512 90451ac2dadcd3f1310b6af977d4c56d239500743a3d67e4f8df915e6e6f65f34d4244843d8bac5718642973be5312c17cb3fb0b4c64732cda06437e9f1ce86d
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libiconv-1.16-1-any.pkg.tar.xz"
        SHA512 c8e2fda532c753e0b1004596bf737c3669355f32af9b45d96c23fcef14994ba21ddf4f75138bdecc94cbf8a8c449eff530d24b74a0da47793e24ce92d154f411
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zlib-1.2.11-7-any.pkg.tar.xz"
        SHA512 bbd4a549efc2a5f4b1e9f1be00331e8726d80401a9c6117afa9d5dd92f4ac42a06cf2ce491a988e5c6ed7a6e536f8f1746081f4944bc6d473ccd16390fea27fe
    )
    msys_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libwinpthread-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst"
        NAME mingw-w64-x86_64-libwinpthread
        VERSION git-8.0.0.5906.c9a21571-1
        ANY
        ZST
        REPO mingw/x86_64
        SHA512 a6969a5db1c55ba458c1a047d0a2a9d2db6cc24266ea47f740598b149a601995d2de734a0984ac5e57ee611d5982cbc03fd6fc0f498435e8d6401bf15724caad
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
