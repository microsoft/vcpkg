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

# Mirror list from https://github.com/msys2/MSYS2-packages/blob/master/pacman-mirrors/mirrorlist.msys
# Sourceforge is not used because it does not keep older package versions
set(Z_VCPKG_ACQUIRE_MSYS_MIRRORS
    "https://www2.futureware.at/~nickoe/msys2-mirror/"
    "https://mirror.yandex.ru/mirrors/msys2/"
    "https://mirrors.tuna.tsinghua.edu.cn/msys2/"
    "https://mirrors.ustc.edu.cn/msys2/"
    "https://mirror.bit.edu.cn/msys2/"
    "https://mirror.selfnet.de/msys2/"
    "https://mirrors.sjtug.sjtu.edu.cn/msys2/"
)

function(z_vcpkg_acquire_msys_download_package out_archive)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "URL;SHA512;FILENAME" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "internal error: z_vcpkg_acquire_msys_download_package passed extra args: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(all_urls "${arg_URL}")

    foreach(mirror IN LISTS Z_VCPKG_ACQUIRE_MSYS_MIRRORS)
        string(REPLACE "https://repo.msys2.org/" "${mirror}" mirror_url "${arg_URL}")
        list(APPEND all_urls "${mirror_url}")
    endforeach()

    vcpkg_download_distfile(msys_archive
        URLS ${all_urls}
        SHA512 "${arg_SHA512}"
        FILENAME "msys-${arg_FILENAME}"
        QUIET
    )
    set("${out_archive}" "${msys_archive}" PARENT_SCOPE)
endfunction()

# writes to the following variables in parent scope:
#   - Z_VCPKG_MSYS_ARCHIVES
#   - Z_VCPKG_MSYS_TOTAL_HASH
#   - Z_VCPKG_MSYS_PACKAGES
function(z_vcpkg_acquire_msys_declare_package)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "NAME;URL;SHA512" "DEPS")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "internal error: z_vcpkg_acquire_msys_declare_package passed extra args: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(required_arg IN ITEMS URL SHA512)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "internal error: z_vcpkg_acquire_msys_declare_package requires argument: ${required_arg}")
        endif()
    endforeach()

    if(NOT arg_URL MATCHES [[^https://repo\.msys2\.org/.*/(([^-]+(-[^0-9][^-]*)*)-.+\.pkg\.tar\.(xz|zst))$]])
        message(FATAL_ERROR "internal error: regex does not match supplied URL to vcpkg_acquire_msys: ${arg_URL}")
    endif()

    set(filename "${CMAKE_MATCH_1}")
    if(NOT DEFINED arg_NAME)
        set(arg_NAME "${CMAKE_MATCH_2}")
    endif()

    if("${arg_NAME}" IN_LIST Z_VCPKG_MSYS_PACKAGES OR arg_Z_ALL_PACKAGES)
        list(REMOVE_ITEM Z_VCPKG_MSYS_PACKAGES "${arg_NAME}")
        list(APPEND Z_VCPKG_MSYS_PACKAGES ${arg_DEPS})
        set(Z_VCPKG_MSYS_PACKAGES "${Z_VCPKG_MSYS_PACKAGES}" PARENT_SCOPE)

        z_vcpkg_acquire_msys_download_package(archive
            URL "${arg_URL}"
            SHA512 "${arg_SHA512}"
            FILENAME "${filename}"
        )

        list(APPEND Z_VCPKG_MSYS_ARCHIVES "${archive}")
        set(Z_VCPKG_MSYS_ARCHIVES "${Z_VCPKG_MSYS_ARCHIVES}" PARENT_SCOPE)
        string(APPEND Z_VCPKG_MSYS_TOTAL_HASH "${arg_SHA512}")
        set(Z_VCPKG_MSYS_TOTAL_HASH "${Z_VCPKG_MSYS_TOTAL_HASH}" PARENT_SCOPE)
    endif()
endfunction()

function(vcpkg_acquire_msys out_msys_root)
    cmake_parse_arguments(PARSE_ARGV 1 "arg"
        "NO_DEFAULT_PACKAGES;Z_ALL_PACKAGES"
        ""
        "PACKAGES;DIRECT_PACKAGES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_acquire_msys was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(Z_VCPKG_MSYS_TOTAL_HASH)
    set(Z_VCPKG_MSYS_ARCHIVES)

    set(Z_VCPKG_MSYS_PACKAGES "${arg_PACKAGES}")

    if(NOT arg_NO_DEFAULT_PACKAGES)
        list(APPEND Z_VCPKG_MSYS_PACKAGES bash coreutils sed grep gawk diffutils make pkg-config)
    endif()

    if(DEFINED arg_DIRECT_PACKAGES AND NOT arg_DIRECT_PACKAGES STREQUAL "")
        list(LENGTH arg_DIRECT_PACKAGES direct_packages_length)
        math(EXPR direct_packages_parity "${direct_packages_length} % 2")
        math(EXPR direct_packages_number "${direct_packages_length} / 2")
        math(EXPR direct_packages_last "${direct_packages_number} - 1")

        if(direct_packages_parity EQUAL 1)
            message(FATAL_ERROR "vcpkg_acquire_msys(... DIRECT_PACKAGES ...) requires exactly pairs of URL/SHA512")
        endif()

        # direct_packages_last > direct_packages_number - 1 > 0 - 1 >= 0, so this is fine
        foreach(index RANGE "${direct_packages_last}")
            math(EXPR url_index "${index} * 2")
            math(EXPR sha512_index "${url_index} + 1")
            list(GET arg_DIRECT_PACKAGES "${url_index}" url)
            list(GET arg_DIRECT_PACKAGES "${sha512_index}" sha512)

            get_filename_component(filename "${url}" NAME)
            z_vcpkg_acquire_msys_download_package(archive
                URL "${url}"
                SHA512 "${sha512}"
                FILENAME "${filename}"
            )
            list(APPEND Z_VCPKG_MSYS_ARCHIVES "${archive}")
            string(APPEND Z_VCPKG_MSYS_TOTAL_HASH "${sha512}")
        endforeach()
    endif()

    # To add new entries, use https://packages.msys2.org/package/$PACKAGE?repo=msys
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/unzip-6.0-2-x86_64.pkg.tar.xz"
        SHA512 b8a1e0ce6deff26939cb46267f80ada0a623b7d782e80873cea3d388b4dc3a1053b14d7565b31f70bc904bf66f66ab58ccc1cd6bfa677065de1f279dd331afb9
        DEPS libbz2
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libbz2-1.0.8-2-x86_64.pkg.tar.xz"
        SHA512 d128bd1792d0f5750e6a63a24db86a791e7ee457db8c0bef68d217099be4a6eef27c85caf6ad09b0bcd5b3cdac6fc0a2b9842cc58d381a4035505906cc4803ec
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/patch-2.7.6-1-x86_64.pkg.tar.xz"
        SHA512 04d06b9d5479f129f56e8290e0afe25217ffa457ec7bed3e576df08d4a85effd80d6e0ad82bd7541043100799b608a64da3c8f535f8ea173d326da6194902e8c
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gzip-1.10-1-x86_64.pkg.tar.xz"
        SHA512 2d0a60f2c384e3b9e2bed2212867c85333545e51ee0f583a33914e488e43c265ed0017cd4430a6e3dafdca99c0414b3756a4b9cc92a6f04d5566eff8b68def75
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/texinfo-6.7-3-x86_64.pkg.tar.zst"
        SHA512 d8bcce1a338d45a8c2350af3edee1d021a76524b767d465d3f7fd9cb03c8799d9cd3454526c10e4a2b4d58f75ae26a1a8177c50079dfdb4299129e0d45b093bc
        DEPS bash perl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/bash-4.4.023-2-x86_64.pkg.tar.xz"
        SHA512 1cf2a07022113010e00e150e7004732013a793d49e7a6ac7c2be27a0b2c0ce3366150584b9974e30df042f8876a84d6a77c1a46f0607e38ebe18f8a25f51c32d
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/autoconf-2.71-1-any.pkg.tar.zst"
        SHA512 c5683bdf72bb3ba28ec0cb6a211ae1f9eebc79d03f17fc8a55d78a35dc6499209936e099d3725573255a48578b71fac6b7b17afb933fd22fe1204daf50689609
        DEPS m4 perl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/autoconf-archive-2019.01.06-1-any.pkg.tar.xz"
        SHA512 77540d3d3644d94a52ade1f5db27b7b4b5910bbcd6995195d511378ca6d394a1dd8d606d57161c744699e6c63c5e55dfe6e8664d032cc8c650af9fdbb2db08b0
        DEPS m4 perl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/diffutils-3.7-1-x86_64.pkg.tar.xz"
        SHA512 0c39837a26b2111bb6310cdfe0bc14656e3d57456ad8023f59c9386634a8f1f236915c79a57348b64c508897c73ed88d8abce2b9ac512a427e9a3956939f2040
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/binutils-2.34-4-x86_64.pkg.tar.zst"
        SHA512 5271288d11489879082bc1f2298bb8bedbcfcf6ee19f8a9b3b552b6a4395543d9385bb833e3c32b1560bff1b411d2be503e2c12a7201bf37b85cfacc5f5baba3
        DEPS libiconv libintl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libtool-2.4.6-9-x86_64.pkg.tar.xz"
        SHA512 b309799e5a9d248ef66eaf11a0bd21bf4e8b9bd5c677c627ec83fa760ce9f0b54ddf1b62cbb436e641fbbde71e3b61cb71ff541d866f8ca7717a3a0dbeb00ebf
        DEPS grep sed coreutils file findutils
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/file-5.39-1-x86_64.pkg.tar.zst"
        SHA512 be51dd0f6143a2f34f2a3e7d412866eb12511f25daaf3a5478240537733a67d7797a3a55a8893e5638589c06bca5af20aed5ded7db0bf19fbf52b30fae08cadd
        DEPS gcc-libs zlib libbz2
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/zlib-1.2.11-1-x86_64.pkg.tar.xz"
        SHA512 b607da40d3388b440f2a09e154f21966cd55ad77e02d47805f78a9dee5de40226225bf0b8335fdfd4b83f25ead3098e9cb974d4f202f28827f8468e30e3b790d
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/bzip2-1.0.8-2-x86_64.pkg.tar.xz"
        SHA512 336f5b59eb9cf4e93b537a212509d84f72cd9b8a97bf8ac0596eff298f3c0979bdea6c605244d5913670b9d20b017e5ee327f1e606f546a88e177a03c589a636
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libbz2-1.0.8-2-x86_64.pkg.tar.xz"
        SHA512 d128bd1792d0f5750e6a63a24db86a791e7ee457db8c0bef68d217099be4a6eef27c85caf6ad09b0bcd5b3cdac6fc0a2b9842cc58d381a4035505906cc4803ec
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/coreutils-8.32-1-x86_64.pkg.tar.xz"
        SHA512 1a2ae4f296954421ce36f764b9b1c77ca72fc8583c46060b817677d0ad6adc7d7e3c2bbe1ae0179afd116a3d62f28e59eae2f7c84c1c8ffb7d22d2f2b40c0cdc
        DEPS libiconv libintl gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/grep-3.0-2-x86_64.pkg.tar.xz"
        SHA512 c784d5f8a929ae251f2ffaccf7ab0b3936ae9f012041e8f074826dd6077ad0a859abba19feade1e71b3289cc640626dfe827afe91c272b38a1808f228f2fdd00
        DEPS libiconv libintl libpcre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/sed-4.8-1-x86_64.pkg.tar.xz"
        SHA512 b6e7ed0af9e04aba4992ee26d8616f7ac675c8137bb28558c049d50709afb571b33695ce21d01e5b7fe8e188c008dd2e8cbafc72a7e2a919c2d678506095132b
        DEPS libintl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libpcre-8.44-1-x86_64.pkg.tar.xz"
        SHA512 e9e56386fc5cca0f3c36cee21eda91300d9a13a962ec2f52eeea00f131915daea1cfeb0e1b30704bf3cc4357d941d356e0d72192bab3006c2548e18cd96dad77
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/m4-1.4.19-1-x86_64.pkg.tar.zst"
        SHA512 8f100fef907ae6668af68538cae559a531761b51bb556d345b752c698fee938a503818cbd2003722d449f6c9a080c7ddabe12dddbee4d407377ca1e96e7d08b1
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/automake-wrapper-11-1-any.pkg.tar.xz"
        SHA512 0fcfc80c31fd0bda5a46c55e9100a86d2fc788a92c7e2ca4fd281e551375c62eb5b9cc9ad9338bb44a815bf0b1d1b60b882c8e68ca3ea529b442f2d03d1d3e1f
        DEPS gawk
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gawk-5.1.0-1-x86_64.pkg.tar.xz"
        SHA512 4e2be747b184f27945df6fb37d52d56fd8117d2fe4b289370bcdb5b15a4cf90cbeaea98cf9e64bcbfa2c13db50d8bd14cbd719c5f31b420842da903006dbc959
        DEPS libintl libreadline mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/mpfr-4.1.0-1-x86_64.pkg.tar.zst"
        SHA512 d64fa60e188124591d41fc097d7eb51d7ea4940bac05cdcf5eafde951ed1eaa174468f5ede03e61106e1633e3428964b34c96de76321ed8853b398fbe8c4d072
        DEPS gmp gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gmp-6.2.0-1-x86_64.pkg.tar.xz"
        SHA512 1389a443e775bb255d905665dd577bef7ed71d51a8c24d118097f8119c08c4dfe67505e88ddd1e9a3764dd1d50ed8b84fa34abefa797d257e90586f0cbf54de8
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/xz-5.2.5-1-x86_64.pkg.tar.xz" # this seems to require immediate updating on version bumps.
        SHA512 99d092c3398277e47586cead103b41e023e9432911fb7bdeafb967b826f6a57d32e58afc94c8230dad5b5ec2aef4f10d61362a6d9e410a6645cf23f076736bba
        DEPS liblzma libiconv gettext
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/liblzma-5.2.5-1-x86_64.pkg.tar.xz"
        SHA512 8d5c04354fdc7309e73abce679a4369c0be3dc342de51cef9d2a932b7df6a961c8cb1f7e373b1b8b2be40343a95fbd57ac29ebef63d4a2074be1d865e28ca6ad
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libreadline-8.0.004-1-x86_64.pkg.tar.xz"
        SHA512 42760bddedccc8d93507c1e3a7a81595dc6392b5e4319d24a85275eb04c30eb79078e4247eb2cdd00ff3884d932639130c89bf1b559310a17fa4858062491f97
        DEPS ncurses
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/ncurses-6.2-1-x86_64.pkg.tar.xz"
        SHA512 d4dc566d3dbd32e7646e328cb350689ede7eaa7008c8ed971072f8869a2986fe3935e7df1700851b52716af7ef20c49f9e6628d3163a5e9208a8872b5014eaea
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/automake1.16-1.16.3-1-any.pkg.tar.zst"
        SHA512 174e6b9d1512eb710d48cda5bb4fef2b5d9b32071f425c76ea32c48081da0281f9fde1aa185845fa68a881233937f8cfd3ebda640d55764c1d48ec50e4de3390
        DEPS perl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/perl-5.32.1-1-x86_64.pkg.tar.zst"
        SHA512 600b919c7299566aa6abf9a432c166fdd81be5ed052ad4062cc54ee952ea556992e8aba25a44757965d66827dc6e98fddb492867399be3bbed44803e17367cb8
        DEPS libcrypt
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libcrypt-2.1-3-x86_64.pkg.tar.zst"
        SHA512 15cee333a82b55ff6072b7be30bf1c33c926d8ac21a0a91bc4cbf655b6f547bc29496df5fa288eb47ca2f88af2a4696f9b718394437b65dd06e3d6669ca0c2e5
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/pkg-config-0.29.2-4-x86_64.pkg.tar.zst"
        SHA512 9f72c81d8095ca1c341998bc80788f7ce125770ec4252f1eb6445b9cba74db5614caf9a6cc7c0fcc2ac18d4a0f972c49b9f245c3c9c8e588126be6c72a8c1818
        DEPS libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/make-4.3-1-x86_64.pkg.tar.xz"
        SHA512 7306dec7859edc27d70a24ab4b396728481484a426c5aa2f7e9fed2635b3b25548b05b7d37a161a86a8edaa5922948bee8c99b1e8a078606e69ca48a433fe321
        DEPS libintl msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gettext-devel-0.19.8.1-1-x86_64.pkg.tar.xz"
        SHA512 648f74c23e4f92145cdd0d45ff5285c2df34e855a9e75e5463dd6646967f8cf34a18ce357c6f498a4680e6d7b84e2d1697ba9deee84da8ea6bb14bbdb594ee22
        DEPS gettext
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gettext-0.19.8.1-1-x86_64.pkg.tar.xz"
        SHA512 c8c42d084c297746548963f7ec7a7df46241886f3e637e779811ee4a8fee6058f892082bb2658f6777cbffba2de4bcdfd68e846ba63c6a6552c9efb0c8c1de50
        DEPS libintl libgettextpo libasprintf tar
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/tar-1.32-1-x86_64.pkg.tar.xz"
        SHA512 379525f4b8a3f21d67d6506647aec8367724e1b4c896039f46845d9e834298280381e7261a87440925ee712794d43074f4ffb5e09e67a5195af810bbc107ad9a
        DEPS libiconv libintl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libgettextpo-0.19.8.1-1-x86_64.pkg.tar.xz"
        SHA512 480b782a79b0ce71ed9939ae3a6821fc2f5a63358733965c62cee027d0e6c88e255df1d62379ee47f5a7f8ffe163e554e318dba22c67dc67469b10aa3248edf7
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libasprintf-0.19.8.1-1-x86_64.pkg.tar.xz"
        SHA512 a2e8027b9bbee20f8cf60851130ca2af436641b1fb66054f8deba118da7ebecb1cd188224dcf08e4c5b7cde85b412efab058afef2358e843c9de8eb128ca448c
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/findutils-4.7.0-1-x86_64.pkg.tar.xz"
        SHA512 fd09a24562b196ff252f4b5de86ed977280306a8c628792930812f146fcf7355f9d87434bbabe25e6cc17d8bd028f6bc68fc02e5bea83137a49cf5cc6f509e10
        DEPS libintl libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libintl-0.19.8.1-1-x86_64.pkg.tar.xz"
        SHA512 4e54c252b828c862f376d8f5a2410ee623a43d70cbb07d0b8ac20c25096f59fb3ae8dcd011d1792bec76f0b0b9411d0e184ee23707995761dc50eb76f9fc6b92
        DEPS libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libiconv-1.16-2-x86_64.pkg.tar.zst"
        SHA512 3ab569eca9887ef85e7dd5dbca3143d8a60f7103f370a7ecc979a58a56b0c8dcf1f54ac3df4495bc306bd44bf36ee285aaebbb221c4eebfc912cf47d347d45fc
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gcc-libs-9.3.0-1-x86_64.pkg.tar.xz"
        SHA512 2816afbf45aa0ff47f94a623ad083d9421bca5284dc55683c2f1bc09ea0eadfe720afb75aafef60c2ff6384d051c4fbe2a744bb16a20acf34c04dc59b17c3d8c
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/msys2-runtime-3.2.0-8-x86_64.pkg.tar.zst"
        SHA512 fdd86f4ffa6e274d6fef1676a4987971b1f2e1ec556eee947adcb4240dc562180afc4914c2bdecba284012967d3d3cf4d1a392f798a3b32a3668d6678a86e8d3
    )

    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-python-numpy-1.19.0-1-any.pkg.tar.zst"
        SHA512 15791fff23deda17a4452c9ca3f23210ed77ee20dcdd6e0c31d0e626a63aeb93d15ed814078729101f1cce96129b4b5e3c898396b003d794a52d7169dd027465
        DEPS mingw-w64-x86_64-openblas mingw-w64-x86_64-python
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-openblas-0.3.10-2-any.pkg.tar.zst"
        SHA512 3cf15ef191ceb303a7e40ad98aca94c56211b245617c17682379b5606a1a76e12d04fa1a83c6109e89620200a74917bcd981380c7749dda12fa8e79f0b923877
        DEPS mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libgfortran-10.2.0-1-any.pkg.tar.zst"
        SHA512 c2dee2957356fa51aae39d907d0cc07f966028b418f74a1ea7ea551ff001c175d86781f980c0cf994207794322dcd369fa122ab78b6c6d0f0ab01e39a754e780
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-python-3.8.5-1-any.pkg.tar.zst"
        SHA512 49bbcaa9479ff95fd21b473a1bc286886b204ec3e2e0d9466322e96a9ee07ccd8116024b54b967a87e4752057004475cac5060605e87bd5057de45efe5122a25
        DEPS mingw-w64-x86_64-bzip2 mingw-w64-x86_64-expat mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libffi mingw-w64-x86_64-mpdecimal mingw-w64-x86_64-ncurses mingw-w64-x86_64-openssl mingw-w64-x86_64-sqlite3 mingw-w64-x86_64-tcl mingw-w64-x86_64-tk mingw-w64-x86_64-xz mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-bzip2-1.0.8-1-any.pkg.tar.xz"
        SHA512 6e01b26a2144f99ca00406dbce5b8c3e928ec8a3ff77e0b741b26aaf9c927e9bea8cb1b5f38cd59118307e10dd4523a0ea2a1ea61f798f99e6d605ef1d100503
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpdecimal-2.5.0-1-any.pkg.tar.zst"
        SHA512 48130ff676c0235bad4648527021e597ee00aa49a4443740a134005877e2ff2ca27b30a0ac86b923192a65348b36de4e8d3f9c57d76ab42b2e21d1a92dbf7ccf
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-ncurses-6.2-1-any.pkg.tar.xz"
        SHA512 1cbffe0e181a3d4ceaa8f39b2a649584b2c7d689e6a057d85cb9f84edece2cf60eddc220127c7fa4f29e4aa6e8fb4f568ef9d73582d08168607135af977407e0
        DEPS mingw-w64-x86_64-libsystre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libsystre-1.0.1-4-any.pkg.tar.xz"
        SHA512 6540e896636d00d1ea4782965b3fe4d4ef1e32e689a98d25e2987191295b319eb1de2e56be3a4b524ff94f522a6c3e55f8159c1a6f58c8739e90f8e24e2d40d8
        DEPS mingw-w64-x86_64-libtre
    )
    z_vcpkg_acquire_msys_declare_package(
        NAME "mingw-w64-x86_64-libtre"
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libtre-git-r128.6fb7206-2-any.pkg.tar.xz"
        SHA512 d595dbcf3a3b6ed098e46f370533ab86433efcd6b4d3dcf00bbe944ab8c17db7a20f6535b523da43b061f071a3b8aa651700b443ae14ec752ae87500ccc0332d
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gettext
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-openssl-1.1.1.g-1-any.pkg.tar.xz"
        SHA512 81681089a19cae7dbdee1bc9d3148f03458fa7a1d2fd105be39299b3a0c91b34450bcfe2ad86622bc6819da1558d7217deb0807b4a7bed942a9a7a786fcd54a3
        DEPS mingw-w64-x86_64-ca-certificates mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-ca-certificates-20200601-1-any.pkg.tar.zst"
        SHA512 21a81e1529a3ad4f6eceb3b7d4e36400712d3a690d3991131573d4aae8364965757f9b02054d93c853eb75fbb7f6173a278b122450c800b2c9a1e8017dd35e28
        DEPS mingw-w64-x86_64-p11-kit
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-p11-kit-0.23.20-2-any.pkg.tar.xz"
        SHA512 c441c4928465a98aa53917df737b728275bc0f6e9b41e13de7c665a37d2111b46f057bb652a1d5a6c7cdf8a74ea15e365a727671b698f5bbb5a7cfd0b889935e
        DEPS mingw-w64-x86_64-gettext mingw-w64-x86_64-libffi mingw-w64-x86_64-libtasn1
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libtasn1-4.16.0-1-any.pkg.tar.xz"
        SHA512 c450cd49391b46af552a89f2f6e2c21dd5da7d40e7456b380290c514a0f06bcbd63f0f972b3c173c4237bec7b652ff22d2d330e8fdf5c888558380bd2667be64
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-sqlite3-3.33.0-1-any.pkg.tar.zst"
        SHA512 eae319f87c9849049347f132efc2ecc46e9ac1ead55542e31a3ea216932a4fa5c5bae8d468d2f050e1e22068ac9fbe9d8e1aa7612cc0110cafe6605032adeb0f
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-readline mingw-w64-x86_64-tcl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-readline-8.0.004-1-any.pkg.tar.xz"
        SHA512 e3fb3030a50f677697bec0da39ba2eb979dc28991ad0e29012cbf1bda82723176148510bf924b7fce7a0b79e7b078232d69e07f3fbb7d657b8ee631841730120
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-termcap
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-termcap-1.3.1-6-any.pkg.tar.zst"
        SHA512 602d182ba0f1e20c4c51ae09b327c345bd736e6e4f22cd7d58374ac68c705dd0af97663b9b94d41870457f46bb9110abb29186d182196133618fc460f71d1300
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-tk-8.6.10-2-any.pkg.tar.zst"
        SHA512 a2d05ce3070d3a3bdf823fa5c790b124aa7493e60758e2911d3f9651899cf58328044f9b06edd82060d8a4b5efb5c4cb32085d827aecd796dbb5e42441da305f
        DEPS mingw-w64-x86_64-tcl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-tcl-8.6.10-1-any.pkg.tar.xz"
        SHA512 c3f21588e19725598878ef13145fbe7a995c2a0c678ef0a4782e28fd64d65fe3271178369bf0c54e92123eba82f2d3da6ae2fc34acd3b20150d1e173be1c0f8f
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-xz-5.2.5-2-any.pkg.tar.zst"
        SHA512 94fcf8b9f9fbc2cfdb2ed53dbe72797806aa3399c4dcfea9c6204702c4504eb4d4204000accd965fcd0680d994bf947eae308bc576e629bbaa3a4cefda3aea52
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gettext
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gettext-0.19.8.1-10-any.pkg.tar.zst"
        SHA512 ebe948028942738918930b1f3b7aa0314ce0fb617dbd36dcfaf3980958555c7c476f2b50c21d272d01fd3b0bb87ac4f800e485a5b7f8fcc7b30aacdf76740348
        DEPS mingw-w64-x86_64-expat mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libs-10.2.0-9-any.pkg.tar.zst"
        SHA512 b2952015e0b27c51219fe15d7550a349e6d73032bbe328f00d6654008c4bda28766d75ce8898d765879ec5f4815695d0f047d01811d8253ed2d433cd5c77d5a9
        DEPS mingw-w64-x86_64-gmp mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpc-1.2.0-2-any.pkg.tar.zst"
        SHA512 f094b3ec407382018b3454afa07ea82b94acf3b92c094c46ab6d27e56cd2647cf5bc4986ecb18f8a5da721fd267dceba25353822e7cac33d9107604ac5d429bc
        DEPS mingw-w64-x86_64-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpfr-4.1.0-3-any.pkg.tar.zst"
        SHA512 be8ad04e53804f18cfeec5b9cba1877af1516762de60891e115826fcfe95166751a68e24cdf351a021294e3189c31ce3c2db0ebf9c1d4d4ab6fea1468f73ced5
        DEPS mingw-w64-x86_64-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gmp-6.2.0-3-any.pkg.tar.zst"
        SHA512 2736ba40bd7cac4ed12aae3d677aa0b788b161d2488976fbbae0fc6cff9ab154a09c903c1eec38ffe408a41abc62fd6106b55e17d7826b6dc10e720053685b1f
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-expat-2.2.10-1-any.pkg.tar.zst"
        SHA512 ea3069abd7b9809186d1204479a49d605797535e5d618c5c4fc068511134ef9a277facd67fc47fa9a00da2018db90291190fdb2187cb6a7bd99331a1c0c7e119
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libffi-3.3-3-any.pkg.tar.zst"
        SHA512 6d7700e218018454e406737108c40328038deb8d159b147b4159192d01fb72f8df90a81cf769c0b452fdab1f2ff110ead2e1894e3804f7e827fa2770349c63f8
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libiconv-1.16-2-any.pkg.tar.zst"
        SHA512 542ed5d898a57a79d3523458f8f3409669b411f87d0852bb566d66f75c96422433f70628314338993461bcb19d4bfac4dadd9d21390cb4d95ef0445669288658
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zlib-1.2.11-9-any.pkg.tar.zst"
        SHA512 f386d3a8d8c169a62a4580af074b7fdc0760ef0fde22ef7020a349382dd374a9e946606c757d12da1c1fe68baf5e2eaf459446e653477035a63e0e20df8f4aa0
    )
    z_vcpkg_acquire_msys_declare_package(
        NAME "mingw-w64-x86_64-libwinpthread"
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libwinpthread-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst"
        SHA512 a6969a5db1c55ba458c1a047d0a2a9d2db6cc24266ea47f740598b149a601995d2de734a0984ac5e57ee611d5982cbc03fd6fc0f498435e8d6401bf15724caad
    )

    if(NOT Z_VCPKG_MSYS_PACKAGES STREQUAL "")
        message(FATAL_ERROR "Unknown packages were required for vcpkg_acquire_msys(${arg_PACKAGES}): ${packages}
This can be resolved by explicitly passing URL/SHA pairs to DIRECT_PACKAGES.")
    endif()

    string(SHA512 total_hash "${Z_VCPKG_MSYS_TOTAL_HASH}")
    string(SUBSTRING "${total_hash}" 0 16 total_hash)
    set(path_to_root "${DOWNLOADS}/tools/msys2/${total_hash}")
    if(NOT EXISTS "${path_to_root}")
        file(REMOVE_RECURSE "${path_to_root}.tmp")
        file(MAKE_DIRECTORY "${path_to_root}.tmp/tmp")
        set(index 0)
        foreach(archive IN LISTS Z_VCPKG_MSYS_ARCHIVES)
            vcpkg_execute_required_process(
                ALLOW_IN_DOWNLOAD_MODE
                COMMAND "${CMAKE_COMMAND}" -E tar xzf "${archive}"
                LOGNAME "msys-${TARGET_TRIPLET}-${index}"
                WORKING_DIRECTORY "${path_to_root}.tmp"
            )
            math(EXPR index "${index} + 1")
        endforeach()
        file(RENAME "${path_to_root}.tmp" "${path_to_root}")
    endif()
    # Due to skipping the regular MSYS2 installer,
    # some config files need to be established explicitly.
    if(NOT EXISTS "${path_to_root}/etc/fstab")
        # This fstab entry removes the cygdrive prefix from paths.
        file(WRITE "${path_to_root}/etc/fstab" "none  /  cygdrive  binary,posix=0,noacl,user  0  0")
    endif()
    message(STATUS "Using msys root at ${path_to_root}")
    set("${out_msys_root}" "${path_to_root}" PARENT_SCOPE)
endfunction()
