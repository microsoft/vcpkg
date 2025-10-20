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
        URL "https://mirror.msys2.org/msys/x86_64/autoconf2.72-2.72-3-any.pkg.tar.zst"
        SHA512 307751b00b6a9729673d0af35ccf327041880f20498143100053a9d914927e86dd20a4aa4cd9e83e3d4e7e27c2d068cfc0313c6cab4f103955e4dafede22f4d0
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
        URL "https://mirror.msys2.org/msys/x86_64/bash-5.2.037-2-x86_64.pkg.tar.zst"
        SHA512 dda8e37b5d7185c1cf935eb8d8a7eec7b6a065c44984486725b27d842a793228cd9586a3b68cef4a4e6bf6f8685aa416628cd8da18184f427e3403d73186bc6f
        PROVIDES sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/binutils-2.44-1-x86_64.pkg.tar.zst"
        SHA512 4bddf315ad028841144c2e1f38a08437f8acde2652f6a32e4ce2dfa59b6c8eb6fec25c3383e944324e16f40c02b88b17c1c5d41b219b4ed0f413c6815f1a1012
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
        URL "https://mirror.msys2.org/msys/x86_64/diffutils-3.12-1-x86_64.pkg.tar.zst"
        SHA512 9b486fa45e827392eda39cff268530b0f3bdc5cc80881b55ae610828f861e6a63b790f395976277085b469423264ade705e5a0ecdf7b22fc8c017fc3d90acc78
        DEPS libiconv libintl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/file-5.46-2-x86_64.pkg.tar.zst"
        SHA512 1225311082642b094991c7467ba88eaca3b16e680d736979b6b7f750468b05f5a410e88f7d211e2159e1e80b6aa84c882b26e68296a27f5ee9c3998b61f73fb5
        DEPS gcc-libs libbz2 liblzma libzstd zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/findutils-4.10.0-2-x86_64.pkg.tar.zst"
        SHA512 d817f31b1130f73ababf004585e540c2adc14b2517ae350c73ef3f9b6c25b92ee377b24f6695980fd815c91fa8c870e574633092bd9436b7dbfb30b9d782b5fc
        DEPS libintl libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gawk-5.3.2-1-x86_64.pkg.tar.zst"
        SHA512 8d33ff3772fcfd666ebf2211b92942f9ee4af6cd80d4f69762cdac0afb8522aad85244a1701df80a9980c8dba58e7b70d757146945e28cb77e80160b27f2a49f
        PROVIDES awk
        DEPS libintl libreadline mpfr sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gcc-libs-13.3.0-1-x86_64.pkg.tar.zst"
        SHA512 f38b33ecc56923bff2e43d7c0fc8a79c752feeb6af9d49ff4bdd919e04ca54e7c6a0710e9c55fc700ad53eba6c4670973d7cc867971a40bcbe3c82932a7d3f38
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gettext-0.22.5-1-x86_64.pkg.tar.zst"
        SHA512 50e1969179c6b33376396f200f6c25f709a6104d253121a8148bc5591b140c6f1729dc703374315a96137fa7cfec2abe427ea63bce243d5c0729cee8964ffbd3
        DEPS libasprintf libgettextpo libintl
    )
    # This package shouldn't be a here
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gettext-devel-0.22.5-1-x86_64.pkg.tar.zst"
        SHA512 6de3e04ba238353df65111120ec4850b49f5797f27626ebc27c561390f75b4b1b25c84ac377f6ab15d586ca3ee3940eaf3aba074db1a50d8b8930c1135eae7cf
        DEPS gettext # libiconv-devel
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gmp-6.3.0-1-x86_64.pkg.tar.zst"
        SHA512 d4e8549e55d4088eca30753f867bf82d9287955209766f488f2a07ecc71bc63ef2c50fcc9d47470ea3b0d2f149f1648d9c2453e366e3eb2c2e2d60939f311a40
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/grep-1~3.0-7-x86_64.pkg.tar.zst"
        SHA512 8a5248d0aa7c8d9e57a810f0b03b76db31ebc3c64158886804fdc82095709d496fee433d3aa744484c6cdcb5877ebe95d03b15486cc7bdb13ba33cfbf71e4e14
        DEPS libiconv libintl libpcre sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gzip-1.14-1-x86_64.pkg.tar.zst"
        SHA512 cc316915d1dc0090b5acb385ce392a3ac2c37e1df4f72198a976f9b0f7c4b42d15cf14229bc06c19c22ce39dca79389e426cff592437e05df77f453ecc6f42c5
        DEPS bash
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libasprintf-0.22.5-1-x86_64.pkg.tar.zst"
        SHA512 26ad060897f86cfa8257657d9ca3f64302c3bf949369ef29edd1d2f1525cbd462351d3177ba036ae91e8dec0c8501afdd5a666c1e51d7693d7f16f05406d35dd
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libbz2-1.0.8-4-x86_64.pkg.tar.zst"
        SHA512 5a7be6d04e55e6fb1dc0770a8c020ca24a317807c8c8a4813146cd5d559c12a6c61040797b062e441645bc2257b390e12dd6df42519e56278a1fe849fe76a1c4
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libgettextpo-0.22.5-1-x86_64.pkg.tar.zst"
        SHA512 a4ea2c576de4dca804d013e257e99a185eacafa558bd3793ece3216a21884c0ff23b5369cd8954bf7258e8cea9ffe9197d8a752baa67b5e895daac83de93d2f0
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libiconv-1.18-1-x86_64.pkg.tar.zst"
        SHA512 77979ed35af45aa5bb7fb6b07d649e8eafa69ebdc8e421c2a7bf69ee567f814b38623a12be0736fb56c17c0aeff69ba769bc52110f62f8e5fdc5bcf334d88d44
        DEPS gcc-libs libintl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libintl-0.22.5-1-x86_64.pkg.tar.zst"
        SHA512 1f1826763bcc252f15a0a5a27fbf596a2b5fad5e092bdff17af8231c373c0de17be7411938068aac0f0a617edbb32533de6619f6c58ebcdec7480c210673af45
        DEPS gcc-libs libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/liblzma-5.8.1-1-x86_64.pkg.tar.zst"
        SHA512 4bace8254eb63c9fd6354beea92c65d34a0ba9258bbd99a1a061adc4c0c33891b83ad10503042984fbb40560dd5f92a6ac4913a269dae00e9d3f850c79d92e71
        # This package installs only a DLL. No extra deps.
        DEPS # gettext libiconv sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libpcre-8.45-5-x86_64.pkg.tar.zst"
        SHA512 3a0fffaf4d24bac07847220bac70b0e3f15645ea04171c5f4079966cbec01cee9138e36e5100b989af2dcce67660756c060fb3298c86fa120779c15d083231eb
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libreadline-8.2.013-1-x86_64.pkg.tar.zst"
        SHA512 31a649a3b694434ce6a1c70ff5fa208a99acf323a6a1b521e1ce8b1cc0cdb9b63df3200ab497ba0e477d6ab61721bdfb133a90156fd88295b4ff9ff2551866cd
        DEPS ncurses
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libtool-2.5.4-1-x86_64.pkg.tar.zst"
        SHA512 65bdd278c19a6f32094d9944ac87418f38966e453f5fca60b2e00966731af88b119b94ef3cb6a68a9fd9a183f846d08a6524b9f273d311987acc308e84e3cf00
        DEPS sh
             # extra deps which are really needed
             awk findutils grep sed tar
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libxcrypt-4.4.38-1-x86_64.pkg.tar.zst"
        SHA512 a23b90d67773a4846cf0aa0a37132f65ca5244a16d04c903ac3807e146a41a4cab033ac12572c95df6f6ad3272ac97097dfc678b1c2da25092ce9ed1e9dddc01
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libzstd-1.5.7-1-x86_64.pkg.tar.zst"
        SHA512 02cf577567773f7f93f4df404d3b0a62d0cab4b2b63c76d572ef3af591e9fe6571b3d7e79e868ae5d7967b8f540941489a4004367c64113e1688f392827fc6cd
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
        URL "https://mirror.msys2.org/msys/x86_64/mpfr-4.2.2-1-x86_64.pkg.tar.zst"
        SHA512 80fa09c637c4ff3943b20a5b74e945c7084e1f7d571d7124a5b45926533a24125a0027167f99eb9c1e9f96fc3d61344e23c0b4471815846d90367bcfb8f89eba
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
            URL "https://mirror.msys2.org/msys/x86_64/msys2-runtime-3.6.2-2-x86_64.pkg.tar.zst"
            SHA512 2a81a6c10347b59bb5de237c07c61ca2468ee9b9c0907d35e8ece4389d6cd18cd24ba1f96655a052c9c8b3d52fe1c62288c96873202e0036b89e500e8beb8d8a
        )
    endif()
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/ncurses-6.5.20240831-2-x86_64.pkg.tar.zst"
        SHA512 ff84849e3857e31fd4f3acc48e8a9bc2fa6ff226f848636c206fb322e7c49de9677c24784575ad5d13620f31d6203739b0f7ab068081bef0d8ab873c4473ee4d
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/patch-2.7.6-3-x86_64.pkg.tar.zst"
        SHA512 dd5069cab243c8367152b1b8799a199103a7a86be2d478a9f4f84406591ad892284859531ec29ca09de8f278e6c97492896a08b6a08bcbc3ac09ac297e653ec0
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/perl-5.38.4-2-x86_64.pkg.tar.zst"
        SHA512 e49ac4b917a3eb9aa354ea88f8b6eb708c3339de6d7fa0fc638314a00e97f4353525bb500ee21a0167c37efcd22f52499daedf8daf296cbfbcaa9f9a852fb080
        DEPS coreutils libxcrypt sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/pkgconf-2.4.3-1-x86_64.pkg.tar.zst"
        SHA512 df86ba01d336f1ca0aef5fa1af49f0e6ef1ccd8625729f31edde01013dd303512c915be04cb72964913140dcbcaa92806013c2d6a8c5d9f1539b2e646c09d669
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
        URL "https://mirror.msys2.org/msys/x86_64/texinfo-7.2-1-x86_64.pkg.tar.zst"
        SHA512 3f8ff7b399defee89ba6add61d23ba6ab87ea059ecd63ffaae05d8e01bd36b5cba3cb0fe177da83857135c03655120a1fca388e6b11cb0f8296c43ccafcab679
        DEPS perl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/unzip-6.0-3-x86_64.pkg.tar.zst"
        SHA512 1d6df49e826617ef3d3976be33361e189d8a5aee3a33ae79474fd08ca44ebd113981e6ba25c968b3cf5fb9826edd42dee21a97261cbc86fd8b143c950ba1f357
        DEPS bash libbz2
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/which-2.23-4-x86_64.pkg.tar.zst"
        SHA512 ad8ad602b76719b13cf8e650ca493fe9433cfd35d48bda33ce38d0523e9ade5702f89a62508ec0e2a453639a78ed54fc212f76ce8861ac58ac81e6eed476397a
        DEPS sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/xz-5.8.1-1-x86_64.pkg.tar.zst"
        SHA512 2f5e01663d21bd4e36cee60e7fc897391a6592052ef8f44a472340883c5ee7b31fe06a8a603828f93c3350cba85db16debcef13a9253f1762938bb5d327e6f08
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ca-certificates-20241223-1-any.pkg.tar.zst"
        SHA512 7ccb46991cb7f0d128ec188639c0d783a9c5c2d83dee7caf1d3a3c7e87b878d626cf91b56ad0023343dee2b1f3867c0d325dae58d0b8c690b9fc8af8543c145e
        DEPS mingw-w64-x86_64-p11-kit
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-expat-2.7.1-2-any.pkg.tar.zst"
        SHA512 dda4607ec07a793b0fa0cc5f93fde1d8842b9f98d5cc826e7f23758486422723fc656c94c79eba263fbfde5ac0ef0f3a13c8725857644b1c428b8da5dfa367f2
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libgfortran-15.1.0-5-any.pkg.tar.zst"
        SHA512 65dfeb735c99d2e112363f5135be14eecb1e56bf88ecd359f40e557f6714ecd1d721e3a8b875ac04c9b53c7e829375501ad8e9c927b484006798e867a9a97d34
        PROVIDES mingw-w64-x86_64-fc-libs
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libs-15.1.0-5-any.pkg.tar.zst"
        SHA512 cfbfc2fa0029ae9dda628cdaea476579a6cdfafeec716986b4e0761f02b755c338e57e1b96c457881109343d1bd8b55be349c2df05bb57ba4449e56f1acb569f
        PROVIDES mingw-w64-x86_64-omp
        DEPS mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gettext-runtime-0.25-1-any.pkg.tar.zst"
        SHA512 c452759c0e10c68540a91f8a29a1600aef164c4fe12f1e7089858304d80e3071e3a953d7506a0f845476df3a30dd8d270a00a3a55d6e9b14dfe69b0d635ea608
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gmp-6.3.0-2-any.pkg.tar.zst"
        SHA512 38ab150051d787e44f1c75b3703d6c8deb429d244acb2a973ee232043b708e6c9e29a1f9e28f12e242c136d433e8eb5a5133a4d9ac7b87157a9749a8d215d2f0
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libffi-3.4.8-1-any.pkg.tar.zst"
        SHA512 2747a6c44b159a8df4ca141273ab13e5348ac273bc8643b6179c0d803d53710f0b807e985531a39c3e5b74be640feeafd57c9adc98e02c0a429ba9bfb5dd2d21
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.18-1-any.pkg.tar.zst"
        SHA512 7aed58286d279699dede96c74e649cea7b78942e51350d277aca9272351d3b645ecfd129b5bbafd40f7e95bfc0187c9df118eca47f2cb795811752a18bcb3745
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libsystre-1.0.2-1-any.pkg.tar.zst"
        SHA512 e5ce0ff1dbf778f8437a33362c4cd517313425944cfc7362cd0bbfd097de835d3ae8aea6696345d9d054517b8146ac564580a33d56a519dbba042ca79cb46317
        PROVIDES mingw-w64-x86_64-libgnurx
        DEPS mingw-w64-x86_64-libtre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtasn1-4.20.0-1-any.pkg.tar.zst"
        SHA512 989beaec97ff400127cafb8202f8e181eecb4ca429ac5b90a3a54cde64e030ce29a259e680ebf7dae223c7374c72632f5f33628e0855387a324f46686cfd8a9b
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtre-0.9.0-1-any.pkg.tar.zst"
        SHA512 5f1797850ab2da94c213cca8663413419b737a17e6856e1d05bcd8d9397d6e0bdb195798b01cb315c1fcf0cffc22a712f13c10e0b5d4103aecef7cd4518c80fb
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwinpthread-12.0.0.r747.g1a99f8514-1-any.pkg.tar.zst"
        SHA512 011f2719ca60437adf8ea653d78592a407eea67f515135164f7437248dca07b11aa5a6bc4769f507ef1b1a1dd0c5c5144fa99613e3eeb6d44dac4a5b48de73bd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpc-1.3.1-2-any.pkg.tar.zst"
        SHA512 3fe183d4af3b3935a4394502eab75a8f7b7692f551fd44e54c67935a4691388d23a021ee1147f0345ed27ffe8a8db3e9e7e37caf2348df3413e0acd519c12a0c
        DEPS mingw-w64-x86_64-gmp mingw-w64-x86_64-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpdecimal-4.0.1-1-any.pkg.tar.zst"
        SHA512 5a2d1b31cb5029e65c95b00f0614123855774b398335491b1bcf81636d55ff7ad4c5e46199f5b23549dd06c47c04edf19e0be65162f3a54034817e30e9834639
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpfr-4.2.2-1-any.pkg.tar.zst"
        SHA512 4795debd7e47a1c539d35e3aa3a6948831a7be77ca8b915273eba7f6dc1f951d2c500f988f78321cf96dea40e4ec8c2a463c12fccdb408f424040f61e7395de7
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ncurses-6.5.20241228-3-any.pkg.tar.zst"
        SHA512 f2930f1eb441686c0403953dd51c664e0ea77f29bcce6c88514ba9510b802e4be4e5ade7da58a989e79d13cc20736e32bf609fb1f297f8949c02326d9800996a
        DEPS mingw-w64-x86_64-libsystre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openblas-0.3.29-3-any.pkg.tar.zst"
        SHA512 040b10db2964a2c94eacdbb2d80b8c42f5ad45113d8b6516a12158b51e80d218d7d67d9c19c193bd24e61c819587679329e093342bff393b2d3c107e899feb09
        DEPS mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-omp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openssl-3.5.0-1-any.pkg.tar.zst"
        SHA512 ede791eba3b6c82184f9649fcb663c72715e7c5f0fcbda87a1226520439c472458f5a3a0a78d4c0e45fb8de2a091cae741341d13404c3ee1995e183ba2efa825
        #DEPS mingw-w64-x86_64-ca-certificates mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-p11-kit-0.25.5-1-any.pkg.tar.zst"
        SHA512 3ecf6cf3f2c774022ed0ae58a1ee63dca84aeabf226b39a69459370d84d13c4ce4e9776be05880ffa7be2da84f504fe051624e1c9378cb49a71e5c0c4d5110e0
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-libffi mingw-w64-x86_64-libtasn1
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-3.12.10-1-any.pkg.tar.zst"
        SHA512 c156c6e74297a5fdd9c299a361acac47b4a9b32859d1d5373e1cb10a29fa91c26a013674ebaad267e434b5de3e31c1649f0701e8ba12bd4688cea34d63b40488
        PROVIDES mingw-w64-x86_64-python3 mingw-w64-x86_64-python3.12
        DEPS mingw-w64-x86_64-bzip2 mingw-w64-x86_64-expat mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libffi mingw-w64-x86_64-mpdecimal mingw-w64-x86_64-ncurses mingw-w64-x86_64-openssl mingw-w64-x86_64-sqlite3 mingw-w64-x86_64-tcl mingw-w64-x86_64-tk mingw-w64-x86_64-xz mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-numpy-2.2.6-1-any.pkg.tar.zst"
        SHA512 f8bfeffdf095e6e0d7e487229cc5475f8a2929902c7cfc4f7c67b7d428adcf80ea88deb6205e84775835d08f7fae53f0b91e4bea816b8dad20f09ad3456bf998
        DEPS mingw-w64-x86_64-openblas mingw-w64-x86_64-python
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-readline-8.2.013-1-any.pkg.tar.zst"
        SHA512 282c8eb6d7241cedbce6d352489b75fc352d154ecd0a259b772f45acc29c2a47a610a8043c7635475bed39b2cca9a45c09845c77c655881dbc7403aa12c65c35
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-termcap
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-sqlite3-3.50.0-1-any.pkg.tar.zst"
        SHA512 799bb830dcf74e832fb3840efdee3afe85f11538eeb78cb66a63f29092b1817718508b67f414581dda0fd470947e6a122bfda0f579c62a33731ba65a4f0be6f9
        PROVIDES mingw-w64-x86_64-sqlite mingw-w64-x86_64-sqlite-analyzer
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-readline mingw-w64-x86_64-tcl mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-termcap-1.3.1-7-any.pkg.tar.zst"
        SHA512 2610355be441fd933f660f8181a5ad074057361a9aadeaad85961230dcf6df5d5165b94ccf9887144c91812485be57c2d79f39e8191ff525889bdff042d34ce6
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-tcl-8.6.16-1-any.pkg.tar.zst"
        SHA512 b36251ad9e5061d332bf9bac80d25ec2b1e7a2ed80a0b88609f7a62b9503b60092ce23ca7ecd39d7a28c44b3e725acb88bb66cfd4e9dec4789d95f3982cba283
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-tk-8.6.16-1-any.pkg.tar.zst"
        SHA512 be8a235fc1f1b8ec5a75ece9314c2c02f0d92302837573b9f651cf57ed1e6387b592699429e48a520073f2077c528d3641cae1f9072a9ec568c21196c708af91
        DEPS mingw-w64-x86_64-tcl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-xz-5.8.1-2-any.pkg.tar.zst"
        SHA512 3309afb4e96cab9406753618abd2851c7b9134ad89d52d0379a45763fa245c4e9265f4cb27c34dcccde785c1e2c728e32344caaf14c62575f0269acdc048f6e0
        DEPS mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zlib-1.3.1-1-any.pkg.tar.zst"
        SHA512 1336cd0db102af495d8bbfc6a1956f365750b19d2377fe809e9b26f61a8a6600394e7343677645c5743f4974161535dad5c0503ff50f6126d27bb927754e7320
    )
endmacro()
