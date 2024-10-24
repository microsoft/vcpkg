# Full mirror list: https://github.com/msys2/MSYS2-packages/blob/master/pacman-mirrors/mirrorlist.msys
set(Z_VCPKG_ACQUIRE_MSYS_MIRRORS
    # Alternative primary
    "https://repo.msys2.org/"
    # Tier 1
    "https://mirror.yandex.ru/mirrors/msys2/"
    "https://mirrors.tuna.tsinghua.edu.cn/msys2/"
    "https://mirrors.ustc.edu.cn/msys2/"
    "https://mirror.selfnet.de/msys2/"
)

# Downloads the given package
function(z_vcpkg_acquire_msys_download_package out_archive)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "URL;SHA512;FILENAME" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "internal error: z_vcpkg_acquire_msys_download_package passed extra args: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    string(REPLACE "https://repo.msys2.org/" "https://mirror.msys2.org/" all_urls "${arg_URL}")
    foreach(mirror IN LISTS Z_VCPKG_ACQUIRE_MSYS_MIRRORS)
        string(REPLACE "https://mirror.msys2.org/" "${mirror}" mirror_url "${arg_URL}")
        list(APPEND all_urls "${mirror_url}")
    endforeach()

    vcpkg_download_distfile(msys_archive
        URLS ${all_urls}
        SHA512 "${arg_SHA512}"
        FILENAME "${arg_FILENAME}"
        QUIET
    )
    set("${out_archive}" "${msys_archive}" PARENT_SCOPE)
endfunction()

# Declares a package
# Writes to the following cache variables:
#   - Z_VCPKG_MSYS_PACKAGES_AVAILABLE
#   - Z_VCPKG_MSYS_${arg_NAME}_URL
#   - Z_VCPKG_MSYS_${arg_NAME}_SHA512
#   - Z_VCPKG_MSYS_${arg_NAME}_FILENAME
#   - Z_VCPKG_MSYS_${arg_NAME}_DEPS
#   - Z_VCPKG_MSYS_${arg_NAME}_PATCHES
#   - Z_VCPKG_MSYS_${arg_NAME}_DIRECT
#   - Z_VCPKG_MSYS_${arg_NAME}_PROVIDES
#   - Z_VCPKG_MSYS_${alias}_PROVIDED_BY
function(z_vcpkg_acquire_msys_declare_package)
    cmake_parse_arguments(PARSE_ARGV 0 arg "DIRECT" "NAME;URL;SHA512" "DEPS;PATCHES;PROVIDES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "internal error: z_vcpkg_acquire_msys_declare_package passed extra args: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(required_arg IN ITEMS URL SHA512)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "internal error: z_vcpkg_acquire_msys_declare_package requires argument: ${required_arg}")
        endif()
    endforeach()

    if(arg_DIRECT)
        if(NOT arg_NAME)
            message(FATAL_ERROR "internal error: z_vcpkg_acquire_msys_declare_package requires argument: NAME")
        endif()
        get_filename_component(filename "${arg_URL}" NAME)
    else()
        if(NOT arg_URL MATCHES [[^https://mirror\.msys2\.org/.*/(([^/]*)-[^-/]+-[^-/]+-[^-/]+\.pkg\.tar\.(xz|zst))$]])
            message(FATAL_ERROR "internal error: regex does not match supplied URL to vcpkg_acquire_msys: ${arg_URL}")
        endif()
        set(filename "msys2-${CMAKE_MATCH_1}")
        if(NOT DEFINED arg_NAME)
            set(arg_NAME "${CMAKE_MATCH_2}")
        endif()
        if(Z_VCPKG_MSYS_${arg_NAME}_DIRECT)
            return()
        endif()
        if(arg_NAME IN_LIST Z_VCPKG_MSYS_PACKAGES_AVAILABLE)
            message(FATAL_ERROR "Redeclaration of package '${arg_NAME}'")
        endif()
    endif()

    list(APPEND Z_VCPKG_MSYS_PACKAGES_AVAILABLE "${arg_NAME}")
    set(Z_VCPKG_MSYS_PACKAGES_AVAILABLE "${Z_VCPKG_MSYS_PACKAGES_AVAILABLE}" CACHE INTERNAL "")
    set(Z_VCPKG_MSYS_${arg_NAME}_URL "${arg_URL}" CACHE INTERNAL "")
    set(Z_VCPKG_MSYS_${arg_NAME}_SHA512 "${arg_SHA512}" CACHE INTERNAL "")
    set(Z_VCPKG_MSYS_${arg_NAME}_FILENAME "${filename}" CACHE INTERNAL "")
    set(Z_VCPKG_MSYS_${arg_NAME}_DEPS "${arg_DEPS}" CACHE INTERNAL "")
    set(Z_VCPKG_MSYS_${arg_NAME}_PATCHES "${arg_PATCHES}" CACHE INTERNAL "")
    set(Z_VCPKG_MSYS_${arg_NAME}_DIRECT "${arg_DIRECT}" CACHE INTERNAL "")
    set(Z_VCPKG_MSYS_${arg_NAME}_PROVIDES "${arg_PROVIDES}" CACHE INTERNAL "")
    foreach(name IN LISTS arg_PROVIDES)
        set(Z_VCPKG_MSYS_${name}_PROVIDED_BY "${arg_NAME}" CACHE INTERNAL "")
    endforeach()
endfunction()

# Collects all required packages to satisfy the given input set
# Writes to the following cache variables:
#   - Z_VCPKG_MSYS_<name>_ARCHIVE
function(z_vcpkg_acquire_msys_download_packages)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "OUT_UNKNOWN;OUT_RESOLVED" "PACKAGES")
    set(backlog "${arg_PACKAGES}")
    list(REMOVE_DUPLICATES backlog)

    list(FILTER arg_PACKAGES EXCLUDE REGEX "^mingw64")
    if(NOT arg_PACKAGES STREQUAL "" AND NOT "msys2-runtime" IN_LIST arg_PACKAGES)
        list(APPEND backlog "msys2-runtime")
    endif()

    set(unknown "")
    set(resolved "")
    set(need_msys_runtime 0)
    while(NOT backlog STREQUAL "")
        list(POP_FRONT backlog name)
        if(DEFINED Z_VCPKG_MSYS_${name}_PROVIDED_BY AND NOT name IN_LIST Z_VCPKG_MSYS_PACKAGES_AVAILABLE)
            set(name "${Z_VCPKG_MSYS_${name}_PROVIDED_BY}")
            if(name IN_LIST resolved)
                continue()
            endif()
        endif()
        if(NOT name IN_LIST Z_VCPKG_MSYS_PACKAGES_AVAILABLE)
            list(APPEND unknown "${name}")
            continue()
        endif()
        list(APPEND resolved "${name}")
        list(REMOVE_ITEM Z_VCPKG_MSYS_${name}_DEPS ${resolved} ${backlog})
        list(APPEND backlog ${Z_VCPKG_MSYS_${name}_DEPS})

        z_vcpkg_acquire_msys_download_package(archive
            URL "${Z_VCPKG_MSYS_${name}_URL}"
            SHA512 "${Z_VCPKG_MSYS_${name}_SHA512}"
            FILENAME "${Z_VCPKG_MSYS_${name}_FILENAME}"
        )
        set(Z_VCPKG_MSYS_${name}_ARCHIVE "${archive}" CACHE INTERNAL "")
    endwhile()
    if(DEFINED arg_OUT_UNKNOWN)
        set("${arg_OUT_UNKNOWN}" "${unknown}" PARENT_SCOPE)
    endif()
    if(DEFINED arg_OUT_RESOLVED)
        set("${arg_OUT_RESOLVED}" "${resolved}" PARENT_SCOPE)
    endif()
endfunction()

# Returns a stable collection of hashes, regardless of package order
function(z_vcpkg_acquire_msys_collect_hashes out_hash)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "" "PACKAGES")
    list(SORT arg_PACKAGES)
    set(result "")
    foreach(name IN LISTS arg_PACKAGES)
        if(NOT DEFINED Z_VCPKG_MSYS_${name}_SHA512)
            message(FATAL_ERROR "SHA512 unknown for '${name}'.")
        endif()
        string(APPEND result "${Z_VCPKG_MSYS_${name}_SHA512}")
        foreach(patch IN LISTS Z_VCPKG_MSYS_${name}_PATCHES)
            file(SHA512 "${patch}" patch_sha)
            string(APPEND result "${patch_sha}")
        endforeach()
    endforeach()
    set(${out_hash} "${result}" PARENT_SCOPE)
endfunction()

function(vcpkg_acquire_msys out_msys_root)
    cmake_parse_arguments(PARSE_ARGV 1 "arg"
        "NO_DEFAULT_PACKAGES;Z_ALL_PACKAGES"
        "Z_DECLARE_EXTRA_PACKAGES_COMMAND"
        "PACKAGES;DIRECT_PACKAGES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_acquire_msys was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    z_vcpkg_acquire_msys_declare_all_packages()
    if(NOT "${arg_Z_DECLARE_EXTRA_PACKAGES_COMMAND}" STREQUAL "")
        cmake_language(CALL "${arg_Z_DECLARE_EXTRA_PACKAGES_COMMAND}")
    endif()
    set(requested "${arg_PACKAGES}")
    if(arg_Z_ALL_PACKAGES)
        set(requested "${Z_VCPKG_MSYS_PACKAGES_AVAILABLE}")
    elseif(NOT arg_NO_DEFAULT_PACKAGES)
        list(APPEND requested bash coreutils file gawk grep gzip diffutils make pkgconf sed)
    endif()

    if(DEFINED arg_DIRECT_PACKAGES AND NOT arg_DIRECT_PACKAGES STREQUAL "")
        list(LENGTH arg_DIRECT_PACKAGES direct_packages_length)
        math(EXPR direct_packages_parity "${direct_packages_length} % 2")
        math(EXPR direct_packages_number "${direct_packages_length} / 2")
        math(EXPR direct_packages_last "${direct_packages_number} - 1")

        if(direct_packages_parity EQUAL 1)
            message(FATAL_ERROR "vcpkg_acquire_msys(... DIRECT_PACKAGES ...) requires exactly pairs of URL/SHA512")
        endif()

        set(direct_packages "")
        # direct_packages_last > direct_packages_number - 1 > 0 - 1 >= 0, so this is fine
        foreach(index RANGE "${direct_packages_last}")
            math(EXPR url_index "${index} * 2")
            math(EXPR sha512_index "${url_index} + 1")
            list(GET arg_DIRECT_PACKAGES "${url_index}" url)
            list(GET arg_DIRECT_PACKAGES "${sha512_index}" sha512)
            get_filename_component(filename "${url}" NAME)
            if(NOT filename MATCHES "^(.*)-[^-]+-[^-]+-[^-]+\.pkg\.tar\..*$")
                message(FATAL_ERROR "Cannot determine package name for '${filename}'")
            endif()
            set(pkg_name "${CMAKE_MATCH_1}")
            z_vcpkg_acquire_msys_declare_package(
                NAME "${pkg_name}"
                URL "${url}"
                SHA512 "${sha512}"
                DIRECT
            )
            list(APPEND direct_packages "${pkg_name}")
        endforeach()
        list(INSERT requested 0 ${direct_packages})
    endif()
 
    z_vcpkg_acquire_msys_download_packages(
        PACKAGES ${requested}
        OUT_RESOLVED resolved
        OUT_UNKNOWN unknown
    )
    if(NOT unknown STREQUAL "")
        message(FATAL_ERROR "Unknown packages were required for vcpkg_acquire_msys(${requested}): ${unknown}
This can be resolved by explicitly passing URL/SHA pairs to DIRECT_PACKAGES.")
    endif()
    set(Z_VCPKG_MSYS_PACKAGES_RESOLVED "${resolved}" CACHE INTERNAL "Export for CI")

    z_vcpkg_acquire_msys_collect_hashes(hashes PACKAGES ${resolved})
    string(SHA512 total_hash "${hashes}")
    string(SUBSTRING "${total_hash}" 0 16 total_hash)
    set(path_to_root "${DOWNLOADS}/tools/msys2/${total_hash}")

    if(NOT EXISTS "${path_to_root}")
        file(REMOVE_RECURSE "${path_to_root}.tmp")
        file(MAKE_DIRECTORY "${path_to_root}.tmp/tmp")
        foreach(name IN LISTS resolved)
            file(ARCHIVE_EXTRACT
                INPUT "${Z_VCPKG_MSYS_${name}_ARCHIVE}"
                DESTINATION "${path_to_root}.tmp"
            )
            if(Z_VCPKG_MSYS_${name}_PATCHES)
                z_vcpkg_apply_patches(
                    SOURCE_PATH "${path_to_root}.tmp"
                    PATCHES ${Z_VCPKG_MSYS_${name}_PATCHES}
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
    # No pkgconfig hints from msys2 installation
    file(REMOVE_RECURSE
        "${path_to_root}/clangarm64/lib/pkgconfig"
        "${path_to_root}/clang64/lib/pkgconfig"
        "${path_to_root}/mingw32/lib/pkgconfig"
        "${path_to_root}/mingw64/lib/pkgconfig"
        "${path_to_root}/ucrt64/lib/pkgconfig"
        "${path_to_root}/usr/lib/pkgconfig"
    )
    message(STATUS "Using msys root at ${path_to_root}")
    set("${out_msys_root}" "${path_to_root}" PARENT_SCOPE)
endfunction()

# Expand this while CMAKE_CURRENT_LIST_DIR is for this file.
set(Z_VCPKG_AUTOMAKE_CLANG_CL_PATCH "${CMAKE_CURRENT_LIST_DIR}/compile_wrapper_consider_clang-cl.patch")

macro(z_vcpkg_acquire_msys_declare_all_packages)
    set(Z_VCPKG_MSYS_PACKAGES_AVAILABLE "" CACHE INTERNAL "")

    # The following list can be updated via test port vcpkg-ci-msys2[update-all].
    # Upstream binary package information is available via
    # https://packages.msys2.org/search?t=binpkg&q=<Pkg>

    # msys subsystem
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/autoconf-wrapper-20240607-1-any.pkg.tar.zst"
        SHA512 e91768eaa3e9ad849c8ab2177593503fb85cda623adfe2e21eb5a34dd58c2c6686bee42cb1d1a6cfe8ae5727fb10edc5e1229e56f96091c25cae4eecc03f191a
        PROVIDES autoconf
        DEPS autoconf2.72 bash sed
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/autoconf2.72-2.72-1-any.pkg.tar.zst"
        SHA512 c8dc3e317dc4befc5f2848ac339a74f9dc8f021767aadb3d2c50b13869e0ef49fb48c62a0a1df5176a15a4f10196fcd2307efb83ff143ba1d20301882ba8dd1e
        DEPS awk bash diffutils m4 perl sed
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/autoconf-archive-2023.02.20-1-any.pkg.tar.zst"
        SHA512 0dbdba67934402eeb974e6738eb9857d013342b4e3a11200710b87fbf085d5bebf49b29b6a14b6ff2511b126549919a375b68f19cc22aa18f6ba23c57290ac72
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/automake-wrapper-20240607-1-any.pkg.tar.zst"
        SHA512 59c219019a776d36cf37a755fdb1c60b0bfd4ef8ec4dc55d2ba5de00e85686cc480d05689d8fa23532615000f3371702c2b2fe31a0f18f92df9f4353202a6e23
        PROVIDES automake
        DEPS automake1.16 automake1.17 bash gawk
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/automake1.16-1.16.5-1-any.pkg.tar.zst"
        SHA512 62c9dfe28d6f1d60310f49319723862d29fc1a49f7be82513a4bf1e2187ecd4023086faf9914ddb6701c7c1e066ac852c0209db2c058f3865910035372a4840a
        DEPS bash perl
        PATCHES "${Z_VCPKG_AUTOMAKE_CLANG_CL_PATCH}"
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/automake1.17-1.17-1-any.pkg.tar.zst"
        SHA512 cb935efc2e303e6f88eee3ab12ca1311c32d3c92e73e04b00b6b9269ce512649efa09af03d22a733f9cc4ebbb99fc64d8dcc123bf68fb914a20bf3cc651375f5
        DEPS bash perl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/bash-5.2.037-1-x86_64.pkg.tar.zst"
        SHA512 c93ea45d4dd603d5cef42b599b4e0ff40b064bfd277eaf6933be35105e085155ebd63b732a2fa703e3878dc26bc288b09a5dfe355531237e3b20c27e1fc12215
        PROVIDES sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/binutils-2.43.1-1-x86_64.pkg.tar.zst"
        SHA512 fb4ceb5f6b472923f654aa320401b7d65063c62c8f4c284996ac1e7f3091e117dafb1d600df164466bc0b56fb5a4d13558b05f707dd91e7801c37df7e9346a5e
        DEPS libiconv libintl zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/bzip2-1.0.8-4-x86_64.pkg.tar.zst"
        SHA512 1d2ce42c6775c0cb0fe9c2863c975fd076579131d0a5bce907355315f357df4ee66869c9c58325f5b698f3aba2413b2823deda86dd27fdb6e2e5e5d4de045259
        DEPS libbz2
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/coreutils-8.32-5-x86_64.pkg.tar.zst"
        SHA512 63f99348e654440458f26e9f52ae3289759a5a03428cf2fcf5ac7b47fdf7bf7f51d08e3346f074a21102bee6fa0aeaf88b8ebeba1e1f02a45c8f98f69c8db59c
        DEPS libiconv libintl gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/diffutils-3.10-1-x86_64.pkg.tar.zst"
        SHA512 7ed406370a699be98bff4eeb156a063de80ac8e332fb1873639e0b95b2e72e626351e24c5ca0021af9c0e56c4a3d91bd6669e6245b21c9d4ebdbb36888d8e39d
        DEPS libiconv libintl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/file-5.45-3-x86_64.pkg.tar.zst"
        SHA512 14f6bb0a19f8c74d5b3fe4e95fcf013c0db3bb270c795009f315a2207ca099efc32a9ab487dee72603c0adbe2949337724bbb28b779c71bbf9c1045ad6e23e72
        DEPS gcc-libs libbz2 liblzma libzstd zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/findutils-4.10.0-2-x86_64.pkg.tar.zst"
        SHA512 d817f31b1130f73ababf004585e540c2adc14b2517ae350c73ef3f9b6c25b92ee377b24f6695980fd815c91fa8c870e574633092bd9436b7dbfb30b9d782b5fc
        DEPS libintl libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gawk-5.3.1-1-x86_64.pkg.tar.zst"
        SHA512 01baeb86f0f604f9eb4e9da5c58e02a1fdc52943a62f66b1c14e1cdf72fb252936d63b25c60e992c0aab8ea146ff6dc9bb15b750bd21f803e4dcb31f5965c5bb
        PROVIDES awk
        DEPS libintl libreadline mpfr sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gcc-libs-13.3.0-1-x86_64.pkg.tar.zst"
        SHA512 f38b33ecc56923bff2e43d7c0fc8a79c752feeb6af9d49ff4bdd919e04ca54e7c6a0710e9c55fc700ad53eba6c4670973d7cc867971a40bcbe3c82932a7d3f38
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gettext-0.22.4-1-x86_64.pkg.tar.zst"
        SHA512 7bd1dc50df8a973a075286fdf115fa30c8a78aa23d2845e2bdeb6068bf3391321d9b3ce3241626453bb660d1a57563bea44eebadf81cb2f98f15fbaf266648ec
        DEPS libasprintf libgettextpo libintl
    )
    # This package shouldn't be a here
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gettext-devel-0.22.4-1-x86_64.pkg.tar.zst"
        SHA512 e7748736014b0aa47f2bc740189a5e8e1bcc99a82ccd02d6f75e226b041704e4f353107df175c0547651a05f5a352ec474a7af693fb33d42a8885e47ac371d2e
        DEPS gettext # libiconv-devel
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gmp-6.3.0-1-x86_64.pkg.tar.zst"
        SHA512 d4e8549e55d4088eca30753f867bf82d9287955209766f488f2a07ecc71bc63ef2c50fcc9d47470ea3b0d2f149f1648d9c2453e366e3eb2c2e2d60939f311a40
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/grep-1~3.0-6-x86_64.pkg.tar.zst"
        SHA512 79b4c652082db04c2ca8a46ed43a86d74c47112932802b7c463469d2b73e731003adb1daf06b08cf75dc1087f0e2cdfa6fec0e8386ada47714b4cff8a2d841e1
        DEPS libiconv libintl libpcre sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gzip-1.13-1-x86_64.pkg.tar.zst"
        SHA512 4dbcfe5df7c213b10f003fc2a15123a5ed0d1a6d09638c467098f7b7db2e4fdd75a7ceee03b3a26c2492ae485267d626db981c5b9167e3acb3d7436de97d0e97
        DEPS bash
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libasprintf-0.22.4-1-x86_64.pkg.tar.zst"
        SHA512 06f353d2020d1e7168f4084e9fc17856a158a67a61098314e4b1d7db075542eb29dfe8a84bd154dad28942ee8eaae1e13a6510a4d2caab4509d9f3ea22db6d87
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libbz2-1.0.8-4-x86_64.pkg.tar.zst"
        SHA512 5a7be6d04e55e6fb1dc0770a8c020ca24a317807c8c8a4813146cd5d559c12a6c61040797b062e441645bc2257b390e12dd6df42519e56278a1fe849fe76a1c4
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libgettextpo-0.22.4-1-x86_64.pkg.tar.zst"
        SHA512 7552bc873331f07a4c006f27fe9f72186eed9717d68c4cbf54a75ff65c9445f874c43ccced2f9fa75ff1602c1209f6f1f4335a6ae6bf9bd5e951292584db7539
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libiconv-1.17-1-x86_64.pkg.tar.zst"
        SHA512 e8fc6338d499ccf3a143b3dbdb91838697de76e1c9582bb44b0f80c1d2da5dcfe8102b7512efa798c5409ba9258f4014eb4eccd24a9a46d89631c06afc615678
        DEPS gcc-libs libintl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libintl-0.22.4-1-x86_64.pkg.tar.zst"
        SHA512 07f41f7fa53967bb5b0aca72255c70d7aeed58ea86b67bd0e765e08c20c50187ef2e775b630c0d48b3afbe62203754f7e8653a5f2e1a87a38b4af5753c7bd232
        DEPS gcc-libs libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/liblzma-5.6.3-1-x86_64.pkg.tar.zst"
        SHA512 9fea23590973d5d2eea6da134ae4d10cd5a989babf135778de15ae0d5f28aad58f74485339d1e76187e3496993d26f4c243256d20dd7a0d77e9ebdc5ed56f124
        # This package installs only a DLL. No extra deps.
        DEPS # gettext libiconv sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libpcre-8.45-4-x86_64.pkg.tar.zst"
        SHA512 e1eb5cb38dce22012527bba2e92f908bf23c7725d77dcbd7fa14597af0f5b413319e0a7dd66555370afffc3b55d6074b8b83fd3c384d31ac505b74db246d54ac
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libreadline-8.2.013-1-x86_64.pkg.tar.zst"
        SHA512 31a649a3b694434ce6a1c70ff5fa208a99acf323a6a1b521e1ce8b1cc0cdb9b63df3200ab497ba0e477d6ab61721bdfb133a90156fd88295b4ff9ff2551866cd
        DEPS ncurses
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libtool-2.4.7-4-x86_64.pkg.tar.zst"
        SHA512 fa2f0d4ac3a5aca38988d6f901407c14185238e6554894fd0b1ebe35ee836388c3649c5547cf529778e2a62ce5a3dafae15568b33c0e5d5535b67bb9c46ac37a
        DEPS sh tar
             # extra deps which are really needed
             awk findutils grep sed
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libxcrypt-4.4.36-1-x86_64.pkg.tar.zst"
        SHA512 457320daebd1aa45461788fb52dd4772fe91c34902201fac81d94ee2cbbfa216b02b3831a3e32a5ac638a3f12ac31fcec94ee95b19696fec6624e10e3dc5ffff
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libzstd-1.5.6-1-x86_64.pkg.tar.zst"
        SHA512 ec13dde8cdb16ea48df6ddd172d60d913446907933f47846d2631c6f52dc874fae0dbf7cab4c0d81b3e643a0483dcc7fe316a429fa79ba06bbc29754fc9afb52
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/m4-1.4.19-2-x86_64.pkg.tar.zst"
        SHA512 7471099ba7e3b47e5b019dc0e563165a8660722f2bbd337fb579e6d1832c0e7dcab0ca9297c4692b18add92c4ad49e94391c621cf38874e2ff63d4f926bac38c
        DEPS bash gcc-libs libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/make-4.4.1-2-x86_64.pkg.tar.zst"
        SHA512 b55caaf0d54b784b5dffcbb75a1862fc7359b91caa1e60234e208de03c74159fd003d68f5dddd387adef752bb13805e654f17ec5cb6add51546b9e30a1091b61
        DEPS libintl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/mpfr-4.2.1-1-x86_64.pkg.tar.zst"
        SHA512 7417bb02a0f1073b8c1a64732463ec178d28f75eebd9621d02117cda1d214aff3e28277bd20e1e4731e191daab26e38333ace007ed44459ce3e2feae27aedc00
        DEPS gmp
    )
    if(X_VCPKG_USE_MSYS2_RUNTIME_3.4) # temporary option, for Windows 7.0 and 8.0, or in case of regressions
        z_vcpkg_acquire_msys_declare_package(
            URL "https://mirror.msys2.org/msys/x86_64/msys2-runtime-3.4-3.4.10-2-x86_64.pkg.tar.zst"
            SHA512 3fa087d4eb4e260785b81d5b6f4400ec128a83ff940da732bf147dfde457224573fa467e735b63c9a138872f5c9830f3684f824b2aa5d344fb95dfb91632f832
            PROVIDES msys2-runtime
        )
    else()
        z_vcpkg_acquire_msys_declare_package(
            URL "https://mirror.msys2.org/msys/x86_64/msys2-runtime-3.5.4-2-x86_64.pkg.tar.zst"
            SHA512 070aeb43385beb0e3f8d5fb28909469765116c222d53c2614f5f080be879eef0b78258334b35e8cda7625d8704efc89133f8b8fa78f309c5d680ae270efdaba8
        )
    endif()
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/ncurses-6.5.20240831-2-x86_64.pkg.tar.zst"
        SHA512 ff84849e3857e31fd4f3acc48e8a9bc2fa6ff226f848636c206fb322e7c49de9677c24784575ad5d13620f31d6203739b0f7ab068081bef0d8ab873c4473ee4d
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/patch-2.7.6-2-x86_64.pkg.tar.zst"
        SHA512 eb484156e6e93da061645437859531f7b04abe6fef9973027343302f088a8681d413d87c5635a10b61ddc4a3e4d537af1de7552b3a13106639e451b95831ec91
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/perl-5.38.2-2-x86_64.pkg.tar.zst"
        SHA512 1d1cff89a0f0b47eb5bea51974a092b42a9c05634391bf2056dcd38557d8b97a3f6e697fb2bbf421beea780f132d8d13ff8e0cec22b24f99811657857691a815
        DEPS coreutils libxcrypt sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/pkgconf-2.3.0-1-x86_64.pkg.tar.zst"
        SHA512 38ad69f7da3bfd81282cbb488cb06fe2e5a2d075a7b96499d588a4c398d6778b4a345807d79ac31520b793194f5466ebdf1d00d886c7fa16c5a347230866b11a
        PROVIDES pkg-config
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/sed-4.9-1-x86_64.pkg.tar.zst"
        SHA512 8006a83f0cc6417e3f23ffd15d0cbca2cd332f2d2690232a872ae59795ac63e8919eb361111b78f6f2675c843758cc4782d816ca472fe841f7be8a42c36e8237
        DEPS libintl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/tar-1.35-2-x86_64.pkg.tar.zst"
        SHA512 86269fe17729e5381f8236a0251088110725c3eb930215b8378b6673e5ee136847997bb6a667fe0398b65b85e3f3a7e4679a0fd4bb2ebcb9429a5d7273a02d54
        DEPS libiconv libintl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/texinfo-7.1.1-1-x86_64.pkg.tar.zst"
        SHA512 b34ea9c4ef5c9ec6ffef9aea84674ad1d8e2456d4efe7117a26761c7ac1048030e0394d52a65876049c4216f5ecde8c7c92ad6fbf5c5e1448b0e39da96d74b1f
        DEPS perl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/unzip-6.0-3-x86_64.pkg.tar.zst"
        SHA512 1d6df49e826617ef3d3976be33361e189d8a5aee3a33ae79474fd08ca44ebd113981e6ba25c968b3cf5fb9826edd42dee21a97261cbc86fd8b143c950ba1f357
        DEPS bash libbz2
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/which-2.21-4-x86_64.pkg.tar.zst"
        SHA512 5323fd6635093adf67c24889f469e1ca8ac969188c7f087244a43b3afa0bf8f14579bd87d9d7beb16a7cd61a5ca1108515a46b331868b4817b35cebcb4eba1d1
        DEPS sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/xz-5.6.3-1-x86_64.pkg.tar.zst"
        SHA512 038094ac7a208b03f41c2caf0b3ca1214b6fc914ef28884d9daa385062cbcfc793b94e29f4d4beb3475728ef2c9b70f9fbc58ec5b41f354c638898601f746917
        DEPS libiconv libintl liblzma
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/zlib-1.3.1-1-x86_64.pkg.tar.zst"
        SHA512 a432b0f927d342b678df706487595eff1b780371548933f956adcf697eea11ddbca2863d9d9fb88675a7040dcfddab56f8f71a8ae4d0cd4969e715545c77e87c
        DEPS gcc-libs
    )

    # mingw64 subsystem
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-bzip2-1.0.8-3-any.pkg.tar.zst"
        SHA512 fb1ae524d7b04e1f35c3101c318136dbe08da8093bda98f6aea7e6c2564fec5f8533fb61cac5001b6425105cd982511964ec04099c6651f990dc3b8baf7f7057
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ca-certificates-20240203-1-any.pkg.tar.zst"
        SHA512 9b1ace77623ea69155112df2aa60dbc83f0dac0db25a2db5f99c40a472e974d6b1fc54b61b71fd57e4166e5741255145da2b19617b1d4a632f1284c5b8d5ca82
        DEPS mingw-w64-x86_64-p11-kit
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-expat-2.6.3-1-any.pkg.tar.zst"
        SHA512 617e67e0d61818c204e10411fd18b006b1fff4a56bec3469d37705c0dee279408779b623bd89f3c6f463d524f1256d6490f341f3f0975b60a48f9f3449dee9e6
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libgfortran-14.2.0-1-any.pkg.tar.zst"
        SHA512 6687d0dc689cec34357c21290fc787b52071c3a4c21e0f91f03404fb714080395e48ec9ff13eef6c151f01938f72ede8b7d941426dcf09e07d29255344d52b32
        PROVIDES mingw-w64-x86_64-fc-libs
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libs-14.2.0-1-any.pkg.tar.zst"
        SHA512 65a6849681f2d24d2aa7299e44188210103c94dc7f052b86c2583bcb3fdad1ba9aadaf25fb0f7bffccfb978a6f0fe2e85b4624711f65b75f82a711e1e7bd75c2
        PROVIDES mingw-w64-x86_64-omp
        DEPS mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gettext-runtime-0.22.5-2-any.pkg.tar.zst"
        SHA512 813eb17f9e03267f1a15b0062777bb1cf4cf51b2319aa0e9b6c6a353f47132faab7d7530c1ff19425607c5dabe8af3aee2847ba2e0768056b5834447f491ae73
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gmp-6.3.0-2-any.pkg.tar.zst"
        SHA512 38ab150051d787e44f1c75b3703d6c8deb429d244acb2a973ee232043b708e6c9e29a1f9e28f12e242c136d433e8eb5a5133a4d9ac7b87157a9749a8d215d2f0
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libffi-3.4.6-1-any.pkg.tar.zst"
        SHA512 49c4d22e4e08f86eb77946b90fcc8d28e56b3565179187c527a1fa6dfb17ac7dd0d513748755a908467539e7d7e733556bda132c223348b2dc074c6e7dc6b31c
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.17-4-any.pkg.tar.zst"
        SHA512 dc703b103291a5b89175c3ddf4282c1a40bcd91549c8f993300671b9afffb28559e118a2c665f47a465bd7286b9e3400c29d42761e0189c425fb156b37783927
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libsystre-1.0.1-6-any.pkg.tar.zst"
        SHA512 826122c30b95166332fa3a5492dfd3e523b3d7339344fa1dd1c9442d72676df281a26bd2c708368001c6518edc34a770ffa581a57b3d3cdd86101566eba1aef7
        PROVIDES mingw-w64-x86_64-libgnurx
        DEPENDS mingw-w64-x86_64-libtre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtasn1-4.19.0-1-any.pkg.tar.zst"
        SHA512 761a7c316914d7f98ec6489fb4c06d227e5956d50f2e233ad9be119cfd6301f6b7e4f872316c0bae3913268c1aa9b224b172ab94130489fbd5d7269ff9064cfb
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtre-0.9.0-1-any.pkg.tar.zst"
        SHA512 5f1797850ab2da94c213cca8663413419b737a17e6856e1d05bcd8d9397d6e0bdb195798b01cb315c1fcf0cffc22a712f13c10e0b5d4103aecef7cd4518c80fb
        PROVIDES mingw-w64-x86_64-libtre-git
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwinpthread-git-12.0.0.r351.gcdf6b16b8-1-any.pkg.tar.zst"
        SHA512 656f2052008b9e21fb9effa9044006dc5278e428af9f3476700c75a3ed09f6f0b9683a2ea13574602d0ae79d22cd663a27c758bf688d15697adbdadaa3b1849d
        PROVIDES mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpc-1.3.1-2-any.pkg.tar.zst"
        SHA512 3fe183d4af3b3935a4394502eab75a8f7b7692f551fd44e54c67935a4691388d23a021ee1147f0345ed27ffe8a8db3e9e7e37caf2348df3413e0acd519c12a0c
        DEPS mingw-w64-x86_64-gmp mingw-w64-x86_64-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpdecimal-4.0.0-1-any.pkg.tar.zst"
        SHA512 a5975bb5b2ee8e28de986fa8951aa023a55ab54a8c70260dfd54437abeb5f9220b01463b200a228c46ca5ba84ea6373a791b087c32fd41a066b4524892caf282
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpfr-4.2.1-2-any.pkg.tar.zst"
        SHA512 03a727e1622b09ed0b6e0cb93a6b1040c31c9504c3f14bd1a2e12b8293153609796bc99882393b343c4d96e45f402f847317a3a65212b972ff96a964e5e52815
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ncurses-6.5.20240831-1-any.pkg.tar.zst"
        SHA512 6ec005bae6cbd6bbd6e708f1b11ec0ff8f604d771bc0ec13c903dfd1374b9e40db9925232a83f5640fa2856756161094326bf822f7b4f0e4941d391f6cce05c4
        DEPS mingw-w64-x86_64-libsystre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openblas-0.3.28-1-any.pkg.tar.zst"
        SHA512 615c1fe95887ad7bc3caf35295519cfc6224cb74a48b900d1608c93427379c335df3858f7cfbe555adfc4c88a9e607c2c8fb8d8f8e18404311b0924c9bcda454
        PROVIDES mingw-w64-x86_64-OpenBLAS
        DEPS mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-omp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openssl-3.3.2-1-any.pkg.tar.zst"
        SHA512 64eb1c99cfde5fd72c02d1ae70c527a55cebc5cb120168af06f030e84e43f07d717190587bb8cb9f7075b6786e9e5791548401d8a8a8b225662163e48560c7a7
        #DEPS mingw-w64-x86_64-ca-certificates mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-p11-kit-0.25.5-1-any.pkg.tar.zst"
        SHA512 3ecf6cf3f2c774022ed0ae58a1ee63dca84aeabf226b39a69459370d84d13c4ce4e9776be05880ffa7be2da84f504fe051624e1c9378cb49a71e5c0c4d5110e0
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-libffi mingw-w64-x86_64-libtasn1
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-3.11.10-1-any.pkg.tar.zst"
        SHA512 f20c99e72071eaef235e2c8b69b5ec46e1152818c73d79dd1042b2d8ad6e7ca176eb1dd4d1e50200a86c0a66a5c1bf5c0a431a183eb4733ed783794488db65ab
        PROVIDES mingw-w64-x86_64-python3 mingw-w64-x86_64-python3.11
        DEPS mingw-w64-x86_64-bzip2 mingw-w64-x86_64-expat mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libffi mingw-w64-x86_64-mpdecimal mingw-w64-x86_64-ncurses mingw-w64-x86_64-openssl mingw-w64-x86_64-sqlite3 mingw-w64-x86_64-tcl mingw-w64-x86_64-tk mingw-w64-x86_64-xz mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-numpy-2.1.1-1-any.pkg.tar.zst"
        SHA512 73d37131fb525083dd1eb94601cb09f5505f9f9b893a92d621ac2b83062bb0152f9b8c2df1db7adaef2f09f8f294e94ab0f660445b003509b87b0f904b11d872
        PROVIDES mingw-w64-x86_64-python3-numpy
        DEPS mingw-w64-x86_64-openblas mingw-w64-x86_64-python
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-readline-8.2.013-1-any.pkg.tar.zst"
        SHA512 282c8eb6d7241cedbce6d352489b75fc352d154ecd0a259b772f45acc29c2a47a610a8043c7635475bed39b2cca9a45c09845c77c655881dbc7403aa12c65c35
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-termcap
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-sqlite3-3.46.1-1-any.pkg.tar.zst"
        SHA512 797daba7133d233c98445082a4cbe308ed0cde597c8ee01e6282f1b7fe7ff273bac1446b2f6fc33436b01254db7b3419b554ecfdbf4e4782082d0603cf5abd3d
        PROVIDES mingw-w64-x86_64-sqlite mingw-w64-x86_64-sqlite-analyzer
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-readline mingw-w64-x86_64-tcl mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-termcap-1.3.1-7-any.pkg.tar.zst"
        SHA512 2610355be441fd933f660f8181a5ad074057361a9aadeaad85961230dcf6df5d5165b94ccf9887144c91812485be57c2d79f39e8191ff525889bdff042d34ce6
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-tcl-8.6.13-1-any.pkg.tar.zst"
        SHA512 e143405ed45da7986d30d2f14bde9dff16fb0ea85a01df45d15cbe8fc52065f5efcb22f8da98962022efbfee3a704fc20e38839ec448cdbb5809336b6b97d550
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-tk-8.6.13-1-any.pkg.tar.zst"
        SHA512 dfe682110999dfd7e03df50cd2719fbaad7410b327dd918af0606a78dce5cfe6fc719739b3ae147053f4e42bb3f294c2767141f30ccd59e5cac90151e5b0b852
        DEPS mingw-w64-x86_64-tcl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-xz-5.6.3-1-any.pkg.tar.zst"
        SHA512 faa5f945e2f9b8a11b3419f9bc0b9179e2bcbda36e540cd2b971849dd7f2a0dd3f4ca54b279823716f168a3970343518737fb2992fc37e252f6800d2b5146a23
        DEPS mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zlib-1.3.1-1-any.pkg.tar.zst"
        SHA512 1336cd0db102af495d8bbfc6a1956f365750b19d2377fe809e9b26f61a8a6600394e7343677645c5743f4974161535dad5c0503ff50f6126d27bb927754e7320
    )
endmacro()
