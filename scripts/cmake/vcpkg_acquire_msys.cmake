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
#   - Z_VCPKG_MSYS_${arg_NAME}_ARCHIVE
#   - Z_VCPKG_MSYS_${arg_NAME}_PATCHES
function(z_vcpkg_acquire_msys_declare_package)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "NAME;URL;SHA512" "DEPS;PATCHES")

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

        list(APPEND Z_VCPKG_MSYS_ARCHIVES "${arg_NAME}")
        set(Z_VCPKG_MSYS_ARCHIVES "${Z_VCPKG_MSYS_ARCHIVES}" PARENT_SCOPE)
        set(Z_VCPKG_MSYS_${arg_NAME}_ARCHIVE "${archive}" PARENT_SCOPE)
        set(Z_VCPKG_MSYS_${arg_NAME}_PATCHES "${arg_PATCHES}" PARENT_SCOPE)
        string(APPEND Z_VCPKG_MSYS_TOTAL_HASH "${arg_SHA512}")
        foreach(patch IN LISTS arg_PATCHES)
            file(SHA512 "${patch}" patch_sha)
            string(APPEND Z_VCPKG_MSYS_TOTAL_HASH "${patch_sha}")
        endforeach()
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

    set(Z_VCPKG_MSYS_TOTAL_HASH "")
    set(Z_VCPKG_MSYS_ARCHIVES "")

    set(Z_VCPKG_MSYS_PACKAGES "${arg_PACKAGES}")

    if(NOT arg_NO_DEFAULT_PACKAGES)
        list(APPEND Z_VCPKG_MSYS_PACKAGES bash coreutils sed grep gawk gzip diffutils make pkg-config)
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
            string(REGEX MATCH "^(([^-]+(-[^0-9][^-]*)*)-.+\.pkg\.tar\.(xz|zst))$" pkg_name "${filename}")
            set(pkg_name "${CMAKE_MATCH_2}")
            list(APPEND Z_VCPKG_MSYS_ARCHIVES "${pkg_name}")
            set(Z_VCPKG_MSYS_${pkg_name}_ARCHIVE "${archive}")
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
        URL "https://repo.msys2.org/msys/x86_64/patch-2.7.6-2-x86_64.pkg.tar.zst"
        SHA512 eb484156e6e93da061645437859531f7b04abe6fef9973027343302f088a8681d413d87c5635a10b61ddc4a3e4d537af1de7552b3a13106639e451b95831ec91
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gzip-1.12-2-x86_64.pkg.tar.zst"
        SHA512 107754050a4b0f8633d680fc05aae443ff7326f67517f0542ce2d81b8a1eea204a0006e8dcf3de42abb3be3494b7107c30aba9a4d3d03981e9cacdc9a32ea854
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/texinfo-7.0.1-1-x86_64.pkg.tar.zst"
        SHA512 5e447f1a7b19d07b6f290f6a7a19a73b57d09027e1c6a4468a365a14d52f5baa6256dc6a42548a15e46d32eaf43085f91396db15276db883e550d13ab32529df
        DEPS bash perl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/bash-5.2.009-1-x86_64.pkg.tar.zst"
        SHA512 c5f0b69f6f7ee23091202f8f9029200f5aee189155f1a856cb4659eb0fdbb7863cd752650762e5c4822cf613948eff18a357fa3166fa56078081495bb0b34702
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        NAME autoconf
        URL "https://repo.msys2.org/msys/x86_64/autoconf-wrapper-15-1-any.pkg.tar.zst"
        SHA512 7c0f0c619100d05c82409567399253efddee9b39fff7dd772e503770afd4accbae2ce96307a20b076faf2e308413cd25e7405e70969608223bc86c7016ec38b8
        DEPS autoconf2.71
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/autoconf2.71-2.71-1-any.pkg.tar.zst"
        SHA512 bf725b7d4440764fb21061c066b765193801a03c7ded03cf19ae85aee87ea54059c4283e56877e4e2a54cfec9ef65874160c2cb76de0d08f2550c6032f07c36e
        DEPS m4 perl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/autoconf-archive-2022.09.03-1-any.pkg.tar.zst"
        SHA512 d8567215c405632cd9ce232982c79aa1e8c063d13aac7c64a0ba84901c26710f0254ab72ab9ab464a9ec3fb7163ed60cb950b1f0509880f3378066b073a83d80
        DEPS m4 perl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/diffutils-3.8-4-x86_64.pkg.tar.zst"
        SHA512 7978067ec6bdefcd3366548e01e8e58d7aed6f282977004275c0b18d39272ac6efd2e7536ef5e00436838c5632ceb6e6d4a812e4317a3baa1a3384e4117d3e6e
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/binutils-2.39-2-x86_64.pkg.tar.zst"
        SHA512 8819a0d21011446291bbb6089ce08349e869dcdf580fc2f4355ceefc23d6725f7bd67e09603859865bd32febbaf5cd0eb83388f7558bf5364459ba59b3a4de3e
        DEPS libiconv libintl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libtool-2.4.7-3-x86_64.pkg.tar.zst"
        SHA512 a202ddaefa93d8a4b15431dc514e3a6200c47275c5a0027c09cc32b28bc079b1b9a93d5ef65adafdc9aba5f76a42f3303b1492106ddf72e67f1801ebfe6d02cc
        DEPS grep sed coreutils file findutils
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/file-5.44-2-x86_64.pkg.tar.zst"
        SHA512 8315cb601f534aa67b8c8a8d0167666ccb50aeb35c16ec16db43869c027bb78f01ed5d6f69fc1ad9786ca259428800bac7f8277bdca95a341262464052ab65de
        DEPS gcc-libs zlib libbz2
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/zlib-1.2.13-1-x86_64.pkg.tar.zst"
        SHA512 8dc7525091cf94b1c0646fd21a336cd984385e7e163f925b1f3f786c8be8b884f6cb9b68f55fdb932104c0eb4c8e270fc8df2ec4742404d2dcd0ad9c3e29e7e8
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/bzip2-1.0.8-4-x86_64.pkg.tar.zst"
        SHA512 1d2ce42c6775c0cb0fe9c2863c975fd076579131d0a5bce907355315f357df4ee66869c9c58325f5b698f3aba2413b2823deda86dd27fdb6e2e5e5d4de045259
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libbz2-1.0.8-4-x86_64.pkg.tar.zst"
        SHA512 5a7be6d04e55e6fb1dc0770a8c020ca24a317807c8c8a4813146cd5d559c12a6c61040797b062e441645bc2257b390e12dd6df42519e56278a1fe849fe76a1c4
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/coreutils-8.32-5-x86_64.pkg.tar.zst"
        SHA512 63f99348e654440458f26e9f52ae3289759a5a03428cf2fcf5ac7b47fdf7bf7f51d08e3346f074a21102bee6fa0aeaf88b8ebeba1e1f02a45c8f98f69c8db59c
        DEPS libiconv libintl gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/grep-1~3.0-6-x86_64.pkg.tar.zst"
        SHA512 79b4c652082db04c2ca8a46ed43a86d74c47112932802b7c463469d2b73e731003adb1daf06b08cf75dc1087f0e2cdfa6fec0e8386ada47714b4cff8a2d841e1
        DEPS libiconv libintl libpcre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/sed-4.9-1-x86_64.pkg.tar.zst"
        SHA512 8006a83f0cc6417e3f23ffd15d0cbca2cd332f2d2690232a872ae59795ac63e8919eb361111b78f6f2675c843758cc4782d816ca472fe841f7be8a42c36e8237
        DEPS libintl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libpcre-8.45-3-x86_64.pkg.tar.zst"
        SHA512 566a2723f5b078a586d80c077f9267afb7badf3640386640a098d76ef9142797e7fa8acef5e638b962d9479206fb443c924750eec00a26bccdc39fb49094963f
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/m4-1.4.19-2-x86_64.pkg.tar.zst"
        SHA512 7471099ba7e3b47e5b019dc0e563165a8660722f2bbd337fb579e6d1832c0e7dcab0ca9297c4692b18add92c4ad49e94391c621cf38874e2ff63d4f926bac38c
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/automake-wrapper-11-4-any.pkg.tar.zst"
        SHA512 175940ebccb490c25d2c431dd025f24a7d0c930a7ee8cb81a44a4989c1d07f4b5a8134e1d05a7a1b206f8e19a2308ee198b1295e31b2e139f5d9c1c077252c94
        DEPS gawk
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gawk-5.2.1-2-x86_64.pkg.tar.zst"
        SHA512 0d056ae2bd906badc4e8ac362bd848800ec0fbe53137c74eb20667b86fa18c7fc0da291c5baec129a8fdfba31216d8500d827475b8ad0e8bcbfb2a0e46ddb95e
        DEPS libintl libreadline mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/mpfr-4.2.0-1-x86_64.pkg.tar.zst"
        SHA512 3804b3fa7bfebd2d504752317a80daafae26be12d64b12cd6b20d16edf44c4470022dbf37ffa7abb68ee69d35016fe753b7cb962ddc1a0b3c45dd3d25a5b92b2
        DEPS gmp gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gmp-6.2.1-2-x86_64.pkg.tar.zst"
        SHA512 b2df273243ba08ed2b1117d2b4826900706859c51c1c39ca6e47df2b44b006b2512f7db801738fdbb9411594bc8bc67d308cf205f7fa1aab179863844218e513
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/xz-5.4.0-1-x86_64.pkg.tar.zst" # this seems to require immediate updating on version bumps.
        SHA512 6c659e311f6dfffe1d1a887d31321ba367d254c1fbc8ee6a137bc667348319bdaa632c9d59918db88fe6edaa5e937f75150b155ee602bd81f6f7646934669333
        DEPS liblzma libiconv gettext
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/liblzma-5.4.0-1-x86_64.pkg.tar.zst"
        SHA512 b6f75c14d698a2102e6dd2521b8a4574d5efea539e3a5a854051ec39abc02524e8c1c07a72e4ea8e59cd166fe862c0b59f8d0950dd922550c3f178fa9b2006cf
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libreadline-8.2.001-1-x86_64.pkg.tar.zst"
        SHA512 2a6ce3e24a0b60a6ab4fde8fca4fdf8bbcf8b90417832c75267d0f3333fb2959fd413237c5fe817cc8196fcd8cbfdd6d44a7d0e23d8e4f5ea5601497033d3076
        DEPS ncurses
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/ncurses-6.3-3-x86_64.pkg.tar.zst"
        SHA512 58b76fa93755c29b43d48ec27f3d4375334b25099e6f2d139b64558797644042469d18139edb01b5908459ff8e4f0f6514ecc5a27681865a50a64c11e4e71921
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/automake1.16-1.16.5-1-any.pkg.tar.zst"
        SHA512 62c9dfe28d6f1d60310f49319723862d29fc1a49f7be82513a4bf1e2187ecd4023086faf9914ddb6701c7c1e066ac852c0209db2c058f3865910035372a4840a
        DEPS perl
        PATCHES "${SCRIPTS}/msys/compile_wrapper_consider_clang-cl.patch"
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/perl-5.36.0-1-x86_64.pkg.tar.zst"
        SHA512 fa83a0451b949155bdba53d71d51381d99e4a28dc0f872c53912c8646a5e1858495b8dcfdb0c235975e41de57bc2464eb1e71ffeab96a25c4aa5327cdaa03414
        DEPS libcrypt
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libcrypt-2.1-4-x86_64.pkg.tar.zst"
        SHA512 8bd56a777326dc8793df8bc7bc837bbfd9fb888d678fbfded8c37449fcc85aa3e318b5a249f773aa38ef4e12d8c58f080dce7db9c322b649702bdba292708ebc
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        NAME pkg-config
        URL "https://repo.msys2.org/msys/x86_64/pkgconf-1.8.0-2-x86_64.pkg.tar.zst"
        SHA512 4fcc1671969098b9b7c79192f90d3c0396ad65cb6efc44fdd7e6e7a37452f0bf4a38fb2ef63e73b0f9883a87c9f248c38b7f66c7d762bfbbd0da1d22aec5b52d
        DEPS libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/make-4.4-1-x86_64.pkg.tar.zst"
        SHA512 b64a53fd3e4e9db0868f690276908a348cfc8365a26ca97bb2a0d6610bfc229d417d0faafe0ddfde1f72fe740b769b65548b1d1c9e04355faf4b8848af0aef33
        DEPS libintl msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gettext-devel-0.21-2-x86_64.pkg.tar.zst"
        SHA512 c8852c4c8cf7810434dab18c7a002e59c2248de93b575097a30a31f4e7f41719855c0f3cf55356173576aab03119139f71dce758df1421b3f23c1ca3520e4261
        DEPS gettext
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gettext-0.21-2-x86_64.pkg.tar.zst"
        SHA512 2f6b95686e6c9cabfdac22994cbd6402dc22da71ab9582205874e7967452be65a25bf73b8994cce679ef43b26a29dec25eb3f233f7126d8c4b2f5ddd28588bd4
        DEPS libintl libgettextpo libasprintf tar
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/tar-1.34-3-x86_64.pkg.tar.zst"
        SHA512 19e063393ef0f7eb18df2755798985e78a171f9aa4a747490a357b108d02a9a6a76cae514dd58da0e48a7dd66857dc251be30535677d9fa02e1640bc165cc004
        DEPS libiconv libintl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libgettextpo-0.21-2-x86_64.pkg.tar.zst"
        SHA512 e5736e2d5b8a7f0df02bab3a4c0e09f5a83069f4ff5554fa176f832b455fe836210686428172a34951db7f4ce6f20ec5428440af06d481fcaa90d632aac4afd2
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libasprintf-0.21-2-x86_64.pkg.tar.zst"
        SHA512 e583ae8a6611f11ce56bdd8c0e420854d253070072776c78358ee052260fb3c7b1a7a53eed5e3f1e555e883fa489bb6154679ffe91c88e0390596805b1799d71
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/findutils-4.9.0-3-x86_64.pkg.tar.zst"
        SHA512 1538733929ecc11bc7c19797577e4cd59cc88499b375e3c2ea4a8ed4d66a1a02f4468ff916046c76195ba92f4c591d0e351371768117a423595d2e43b3321aad
        DEPS libintl libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libintl-0.21-2-x86_64.pkg.tar.zst"
        SHA512 fd066ea0fa9bc67fe3bcb09ba4d9dd4524611840bb3179e521fa3049dc88ba5e49851cc04cb76d8f0394c4ec1a6bf45c3f6ce6231dc5b0d3eb1f91d983b7f93b
        DEPS libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/libiconv-1.17-1-x86_64.pkg.tar.zst"
        SHA512 e8fc6338d499ccf3a143b3dbdb91838697de76e1c9582bb44b0f80c1d2da5dcfe8102b7512efa798c5409ba9258f4014eb4eccd24a9a46d89631c06afc615678
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/gcc-libs-11.3.0-2-x86_64.pkg.tar.zst" # 05-Jul-2022
        SHA512 64ca8c3ea23f18dded817828d7ac2722f31803efd1e47a1ad3b9fc14c412666b875a6f3a3bd87a0556a910aeafde8fbf7a874c467a3dbd090314f56704868e61
        DEPS msys2-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/msys2-runtime-3.4.3-5-x86_64.pkg.tar.zst" # 09-Dec-2022
        SHA512 e745385c9ddf41438dceb53bf518a3a1048c158686d340d38d5fd372ac9dc3f69b2beb2d8d4ebbb459ac728f6a4aa0db3104ca4f3fc2942d4e692e47c3e8cd60
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/msys/x86_64/which-2.21-4-x86_64.pkg.tar.zst"
        SHA512 5323fd6635093adf67c24889f469e1ca8ac969188c7f087244a43b3afa0bf8f14579bd87d9d7beb16a7cd61a5ca1108515a46b331868b4817b35cebcb4eba1d1
    )

    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-python-numpy-1.23.5-1-any.pkg.tar.zst"
        SHA512 f42b0dd142b4b377a227970a84b5906674072399aa63cc66846b8b590a4170fc4aa8be39c2747066fd462178df795020a972eaa603101befeb81266ebac6ce5b
        DEPS mingw-w64-x86_64-openblas mingw-w64-x86_64-python
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-openblas-0.3.21-7-any.pkg.tar.zst"
        SHA512 e1e49f477cb44f00b5f8760f9c25bd24746844fd076ca0c490b882cfe31204ae100692387e83de22cd89093c102ae751b99bca9dd2d328aaf5de0e401a531e8a
        DEPS mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libgfortran-12.2.0-7-any.pkg.tar.zst"
        SHA512 2da7cc106384136ff11b889e54fe7817917508077831618f8dfb94311fbcf487fcf3ebb724dcbc7716fa878557f7e702882e9206c289413d1ade6fc247c858a0
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-python-3.10.9-2-any.pkg.tar.zst"
        SHA512 448eed7d2fb703a456bfc7023c251f7f85bfdbc47e770a41e1253695a42d03ed08d479769f3deb397f1a1f4877d85fe37aec55c84396fceae6878e18292079a7
        DEPS mingw-w64-x86_64-bzip2 mingw-w64-x86_64-expat mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libffi mingw-w64-x86_64-mpdecimal mingw-w64-x86_64-ncurses mingw-w64-x86_64-openssl mingw-w64-x86_64-sqlite3 mingw-w64-x86_64-tcl mingw-w64-x86_64-tk mingw-w64-x86_64-xz mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-bzip2-1.0.8-2-any.pkg.tar.zst"
        SHA512 4f7ba44189d953d4d00e7bbf5a7697233f759c92847c074f0f2888d2a641c59ce4bd3c39617adac0ad7b53c5836e529f9ffd889f976444016976bb517e5c24a2
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpdecimal-2.5.1-1-any.pkg.tar.zst"
        SHA512 1204c31367f9268ffd6658be04af7687c01f984c9d6be8c7a20ee0ebde1ca9a03b766ef1aeb1fa7aaa97b88a57f7a73afa7f7a7fed9c6b895a032db11e6133bf
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-ncurses-6.3-6-any.pkg.tar.zst"
        SHA512 4bc38d9d2e81ae4a74eaa43f788742fb359c7d9bc72d9ec637fcc53f7ee4db36b5f14ce9cc270e535071e970af75275c9139ec7da68e08c4be7edce17c38b8a1
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
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-openssl-3.0.7-1-any.pkg.tar.zst"
        SHA512 b27f8e916a520146350f4519718b990b315f8e5875138292b9f62cee85acb8200345af19da698691ab963ae79a06d35bdaa1cc7233df55475e5c53a470d47763
        DEPS mingw-w64-x86_64-ca-certificates mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-ca-certificates-20210119-1-any.pkg.tar.zst"
        SHA512 5590ca116d73572eb336ad73ea5df9da34286d8ff8f6b162b38564d0057aa23b74a30858153013324516af26671046addd6bcade221e94e7b8ed5e8f886e1c58
        DEPS mingw-w64-x86_64-p11-kit
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-p11-kit-0.24.1-3-any.pkg.tar.zst"
        SHA512 4382a1dde73c2b24005f29b3e890d5846524becc51a5ad97e1042fe39e0ab903604450517a44032441ff8b61c76cbcb12612faf90097fdb027a742396a808ce7
        DEPS mingw-w64-x86_64-gettext mingw-w64-x86_64-libffi mingw-w64-x86_64-libtasn1
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libtasn1-4.19.0-1-any.pkg.tar.zst"
        SHA512 761a7c316914d7f98ec6489fb4c06d227e5956d50f2e233ad9be119cfd6301f6b7e4f872316c0bae3913268c1aa9b224b172ab94130489fbd5d7269ff9064cfb
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-sqlite3-3.40.1-1-any.pkg.tar.zst"
        SHA512 8b39a7370deb05163194fe0c477151a07e97f8d677485bc3fa5848324e8d40231b5b49a38ad89dc3be2df9d7973a357bc1e857d607be5ee88b047eff02b5e1d1
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-readline mingw-w64-x86_64-tcl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-readline-8.2.001-6-any.pkg.tar.zst"
        SHA512 7b09a854b2225732b8452f6df7ebb378463066da3801ea29372c52ff68b2f6be5ccf8adf3d7d15a75e6fb3d471c5ade7bd4b9fc9599116d269c00bd9adde566e
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-termcap
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-termcap-1.3.1-6-any.pkg.tar.zst"
        SHA512 602d182ba0f1e20c4c51ae09b327c345bd736e6e4f22cd7d58374ac68c705dd0af97663b9b94d41870457f46bb9110abb29186d182196133618fc460f71d1300
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-tk-8.6.12-1-any.pkg.tar.zst"
        SHA512 d3eb26a0fa4986ba4f6c77baf48d6fa9d623500f0b72aac9a385ff3c242dc8842eb80b563490995c162869fe3366e8b89d65561b4810b6b661ebbff2161428bf
        DEPS mingw-w64-x86_64-tcl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-tcl-8.6.12-1-any.pkg.tar.zst"
        SHA512 145e4a1e3093da20cd6755ca8d2b04f7ace87e3ac952d3593880d57f6719a4767ca315543a4f82ee5cb37cff311ff29c446b36484568f65fb6d0c58706763b9b
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-xz-5.2.9-1-any.pkg.tar.zst"
        SHA512 f9101cc430ac6ec9235c3ec09d9c9c375dac7ad232743256bd8a88953f6fb7d5278f013103dfe4f6cf89d4f0f54a3a76d8b8aae0c3d06f5c32c86d1ca4136885
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gettext
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gettext-0.21-3-any.pkg.tar.zst"
        SHA512 38daa0edd1a2c1efdd56baeb6805d10501a57e0c8ab98942e4a16f8b021908dac315513ea85f5278adf300bce3052a44a3f8b473adb0d5d3656aa4a48fe61081
        DEPS mingw-w64-x86_64-expat mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libs-12.2.0-7-any.pkg.tar.zst"
        SHA512 59190030820da8602f692f411ae7f1bd67d02dd969f904c0626464d3b9b6a0e02fd7cfe5e13e34ba06743caaf59896240ad23284e9ddd012173079d3a19b88f1
        DEPS mingw-w64-x86_64-gmp mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpc-1.3.1-1-any.pkg.tar.zst"
        SHA512 57b86866e2439baa21f296ecb5bdfd624a155dbd260ffe157165e2f8b20bc6fbd5cc446d25dee61e9ed8c28aca941e6f478be3c2d70393f160ed5fd8438e9683
        DEPS mingw-w64-x86_64-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpfr-4.2.0-1-any.pkg.tar.zst"
        SHA512 5c8edf4f5ab59afa51cbf1c5ae209583feebaea576e7e3abb59d7e448fe13e143993e6f35117c26ccc221bc6efc44568119c2e25d469c726a592a026b2498d92
        DEPS mingw-w64-x86_64-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gmp-6.2.1-4-any.pkg.tar.zst"
        SHA512 49befa203d330a24f807476b9bc2d4f75404dd26f5e33c6d6571e844fe575f0e5071915d8534a5913ea28998a4dd68ce7c4f6240cf2f5bd9fb6e7896f1905159
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-expat-2.5.0-1-any.pkg.tar.zst"
        SHA512 b49ec84750387af5b73a78d654673d62cf0e2cb2b59b4d25acb7eca3830018f7a2aefe600d67d843417cfbdd97db81ecfd49a8811e312f53b42c21fb106b230d
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libffi-3.4.4-1-any.pkg.tar.zst"
        SHA512 ec88a0e0cb9b3ff3879d3fd952d3ad52f0d86a42669eddaeca47778ab0d5213abdea7d480a23aa3870e08d6b93b9c4988855e368474be7186e9719456baae5df
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libiconv-1.17-1-any.pkg.tar.zst"
        SHA512 00d61504687ebf6d820e10e0277f94dd76244804efa5f764678890ea1dd050df208c8455ef7ca13476cf001f559bd437970d287bfee84ef2abf28d080c6231c5
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zlib-1.2.13-2-any.pkg.tar.zst"
        SHA512 aa07d4570f1924bb37bc21e98a592432a70000e4e98a03eb353b9525e131ec908164ae7f1c74e65d56ce45ca3705beb38c422571f52f30e6e61d77536afa42b7
    )
    z_vcpkg_acquire_msys_declare_package(
        NAME "mingw-w64-x86_64-libwinpthread"
        URL "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libwinpthread-git-10.0.0.r202.g4359b3570-1-any.pkg.tar.zst"
        SHA512 8fe21ddd035cacc2149dab9f753bbf6a581a20132ea352f707c0ee8d9d2451284b9ffe46164de061ebcfb7990d1e174b8f664c4868ad4025de76cfd9c26df312
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
                COMMAND "${CMAKE_COMMAND}" -E tar xzf "${Z_VCPKG_MSYS_${archive}_ARCHIVE}"
                LOGNAME "msys-${TARGET_TRIPLET}-${index}"
                WORKING_DIRECTORY "${path_to_root}.tmp"
            )
            math(EXPR index "${index} + 1")
            if(Z_VCPKG_MSYS_${archive}_PATCHES)
                z_vcpkg_apply_patches(
                    SOURCE_PATH "${path_to_root}.tmp"
                    PATCHES ${Z_VCPKG_MSYS_${archive}_PATCHES}
                )
            endif()
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
