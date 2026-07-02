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
        URL "https://mirror.msys2.org/msys/x86_64/autoconf-wrapper-20260320-1-any.pkg.tar.zst"
        SHA512 87f793f5c7d01cf2719b75cf898db9a46ceccb7d3c4c19944abf6f6ce30e91898c274434e97d0f3d06a5edf989a792c87fadb04e40175217de9f0c9e3d21ed13
        PROVIDES autoconf
        DEPS autoconf2.72 bash sed
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/autoconf2.72-2.72-4-any.pkg.tar.zst"
        SHA512 d164e3089d0a8836e5fee2d8f9d625eb42e1730db2a3b0155bc412b89301f6246609c5e4343d5d14df33d446a934ccf48777f35c3a6cb02de63b60223eacdf9e
        DEPS awk bash diffutils m4 perl sed
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/autoconf-archive-2024.10.16-1-any.pkg.tar.zst"
        SHA512 bb7a1a14d5e291da646c00e0bcc6663500c9c0ac00079a88d06956fa2e37749c3c2431cba647e41ce3840f323b73198ea0cf54e07014ac2345de47e7069d0581
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/automake-wrapper-20260320-1-any.pkg.tar.zst"
        SHA512 ff5c418249d02badf3da4ffdf83976c923e88755d8145df58477c559e2f020180134c88ac2808d5173698e263135fe03ff6ebaaaf823a641d483c7e8eb199cca
        PROVIDES automake
        DEPS automake1.16 automake1.17 automake1.18 bash gawk
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
        URL "https://mirror.msys2.org/msys/x86_64/automake1.18-1.18.1-1-any.pkg.tar.zst"
        SHA512 d994eb278c5f341d6fe4b89a9034d486b2eaa880c0bd84160862352f964786d7d2220d91549515f02c2d01b5a978be7e8e1551ed2e89ddd449cfbcf05f6354e5
        DEPS bash perl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/bash-5.3.009-1-x86_64.pkg.tar.zst"
        SHA512 b142bab3f4ae6b17a397c80186eab2e564be75dbc6a16f8b4d010e2be7d0e99a8053518a7b050a34c7914b4d2eae731c8ca41fd9061ef4f825540db063fe5c6c
        PROVIDES sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/binutils-2.46-1-x86_64.pkg.tar.zst"
        SHA512 a726985cc4beeac0da5f2743bf6f8b1a56dc3f83c3ecf0857134de0a707fcefd7dfc90719cd40dafbaa2f812c9cfe0b4243747d9ea76e2a1b2285a123d4df59b
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
        URL "https://mirror.msys2.org/msys/x86_64/file-5.47-1-x86_64.pkg.tar.zst"
        SHA512 2c7fe1a3b02dd38548d1db67bd7e447acc1c7428bcb5ffa2d4be7c745011b2f1faa090e2eaa9f5067b3265175e752bda88715ec8063b6682e3b90995d9bfd7d4
        DEPS gcc-libs libbz2 liblzma libzstd zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/findutils-4.10.0-2-x86_64.pkg.tar.zst"
        SHA512 d817f31b1130f73ababf004585e540c2adc14b2517ae350c73ef3f9b6c25b92ee377b24f6695980fd815c91fa8c870e574633092bd9436b7dbfb30b9d782b5fc
        DEPS libintl libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gawk-5.4.0-1-x86_64.pkg.tar.zst"
        SHA512 72f4b5cb68e2550bbb70655d85bb5c61eb9a2c427d57ac70ef4713224a76d2c0464a97a108223f7b21ef7c776a4b1d5cc36f892975a2c715a50a5a6d5888d204
        PROVIDES awk
        DEPS libintl libreadline mpfr sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gcc-libs-15.2.0-1-x86_64.pkg.tar.zst"
        SHA512 1d7705870a3e65f4c485d9572f179b8ae1e9837c558ca1448ba1e94faa836ae0a87b19b8b53965f5c783267f2497926589b42112c9e3a9ef64aae21918d9dc63
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
        URL "https://mirror.msys2.org/msys/x86_64/gmp-6.3.0-2-x86_64.pkg.tar.zst"
        SHA512 739ef6b80f98cac58020d559f407fdabf0f70a1fd8ced4d2473d67427a263ea87ded3efd6c38c221e0a80c7791991c940d7823364eee594ad40cd03694a6d36e
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
        URL "https://mirror.msys2.org/msys/x86_64/libiconv-1.19-1-x86_64.pkg.tar.zst"
        SHA512 326c3edaff3c1b8982cd5bec7c07fffd0da776271ed16b0ff0ea66c004d937194376f6804ecf35901df4e766879c774a624294d2b383dcea5f53f20257452170
        DEPS gcc-libs libintl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libintl-0.22.5-1-x86_64.pkg.tar.zst"
        SHA512 1f1826763bcc252f15a0a5a27fbf596a2b5fad5e092bdff17af8231c373c0de17be7411938068aac0f0a617edbb32533de6619f6c58ebcdec7480c210673af45
        DEPS gcc-libs libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/liblzma-5.8.3-1-x86_64.pkg.tar.zst"
        SHA512 1adc4cb0c5c9c3ea3b30a7b7a193244c91b05494c7177e9bcbf6e565b8a90a0a85e18dfd06248a83f1cd54c66bc19101b69486b594c6b9ad26219a207232d8ab
        # This package installs only a DLL. No extra deps.
        DEPS # gettext libiconv sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libpcre-8.45-5-x86_64.pkg.tar.zst"
        SHA512 3a0fffaf4d24bac07847220bac70b0e3f15645ea04171c5f4079966cbec01cee9138e36e5100b989af2dcce67660756c060fb3298c86fa120779c15d083231eb
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libreadline-8.3.003-1-x86_64.pkg.tar.zst"
        SHA512 216c30e8307c0f72994d52955e4c00ef08f16d8bd9bd82db92c0294a81db05849202c670c62cd5060e871fdcc6d3cb34fbb51e9b0a9ea3a67c6104d384aeb5d3
        DEPS ncurses
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libtool-2.5.4-4-x86_64.pkg.tar.zst"
        SHA512 72589fe4526fffac7aaea38a86c2c037cf1094f7bfe1be65543221a3104dfa2ef7d8d6adb8758119c1a74368c881d690988cd3cbe7502a5202d351382271c9c5
        DEPS bash
             # extra deps which are really needed
             awk findutils grep sed tar
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libxcrypt-4.5.2-1-x86_64.pkg.tar.zst"
        SHA512 98b775bc22fe120846b60353483f3ce8f9aacb33941392a49c96720e0217a76ee44cf867dcd61055d65933e0eae157af6d99bcd2221ab512de876030d76ccb9a
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libzstd-1.5.7-1-x86_64.pkg.tar.zst"
        SHA512 02cf577567773f7f93f4df404d3b0a62d0cab4b2b63c76d572ef3af591e9fe6571b3d7e79e868ae5d7967b8f540941489a4004367c64113e1688f392827fc6cd
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/m4-1.4.21-1-x86_64.pkg.tar.zst"
        SHA512 fcb1254c5df1b4760ca5af3ad109f06b659a51e43eef6a498c2af70dc3ce5150d8f1938cad47fa7be0eac97e447ac5a38ac63ee16383fce445dcf7cc766ad76f
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
            URL "https://mirror.msys2.org/msys/x86_64/msys2-runtime-3.6.9-1-x86_64.pkg.tar.zst"
            SHA512 1269811b83fecf7bf381f4c7ebc33a4b5c5da556b3c2addba2d09fc61f5255e31888813c9e40424ce069e6cd7bd29c874780260b8b723b20d30caefde7b60f10
        )
    endif()
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/ncurses-6.6-1-x86_64.pkg.tar.zst"
        SHA512 1615a2cd2c8ed6028065ae397073eb0f36fbf56f9088f58a38b7192d5e2269dae189885f283be70ab6f806c3b592695e462f9f86881bc2b5aea696b4d915f624
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/patch-2.7.6-3-x86_64.pkg.tar.zst"
        SHA512 dd5069cab243c8367152b1b8799a199103a7a86be2d478a9f4f84406591ad892284859531ec29ca09de8f278e6c97492896a08b6a08bcbc3ac09ac297e653ec0
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/perl-5.42.2-1-x86_64.pkg.tar.zst"
        SHA512 d4c7c2681890aeb1e5f8b984ff085a5a254de769f3d416d1513fea18ed059463a5e713b0056362a02f33a0174733edad90afae5ff9b5d10a106c147722d20a54
        DEPS coreutils libxcrypt sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/pkgconf-2.5.1-1-x86_64.pkg.tar.zst"
        SHA512 5af92108c94896a0bef549ef248909a30627259e25d845f08e028bd23ac1d10004868d2bf8bf35d6e27a363aa30d0a8b1bb312ac15fc8fc18207e2c92e37c2c1
        PROVIDES pkg-config
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/sed-4.9-1-x86_64.pkg.tar.zst"
        SHA512 8006a83f0cc6417e3f23ffd15d0cbca2cd332f2d2690232a872ae59795ac63e8919eb361111b78f6f2675c843758cc4782d816ca472fe841f7be8a42c36e8237
        DEPS libintl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/tar-1.35-3-x86_64.pkg.tar.zst"
        SHA512 73ad6a144c259368f4307b9570b8dd6faf57b2c3fc5af32e311621edc757efa33d99abdb26aecad682f91eee11414c9e5b9b104bb028a58a952b1f736b4cbc2e
        DEPS libiconv libintl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/texinfo-7.2-3-x86_64.pkg.tar.zst"
        SHA512 8dc457aa5d5438093d2e5f8cb91e6da65ff7bc9234799eefbe46c68b9833e2089dfddbf222eba1aa87ac600df5fa12bb5d3ed4b7608e08788d46a57ed4effb1d
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
        URL "https://mirror.msys2.org/msys/x86_64/xz-5.8.3-1-x86_64.pkg.tar.zst"
        SHA512 ea464fea3301e23d80b55f112e7a4a0971593312353a98d37d2fd74e6c5426715d8db578128615eac5563832ed8711d185233364689218fa6b9245933602c7c0
        DEPS libiconv libintl liblzma
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/zlib-1.3.2-1-x86_64.pkg.tar.zst"
        SHA512 248de8c6181252afcdec15ca2ddc0079c5a71f9e153a10eae0e613e8c252ad6c7bd4f326c50dc94ba1d0725e2f93a00548ade86e0daf7156758332c555ad34a2
        DEPS gcc-libs
    )

    # mingw64 subsystem
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-bzip2-1.0.8-3-any.pkg.tar.zst"
        SHA512 fb1ae524d7b04e1f35c3101c318136dbe08da8093bda98f6aea7e6c2564fec5f8533fb61cac5001b6425105cd982511964ec04099c6651f990dc3b8baf7f7057
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ca-certificates-20250419-1-any.pkg.tar.zst"
        SHA512 f005061251cfb3dc540f4fe815b35b4078c06c39960067799dfc10656630d2e236f41f763c5b2d40a7ac9dd8af54402d9219f11abe4bde7792a95ee5f04dbeb4
        DEPS mingw-w64-x86_64-p11-kit
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-expat-2.8.0-1-any.pkg.tar.zst"
        SHA512 77907697cdb67226d13794287d89280c862fd3bd0b5af8a82293b0294ecf6f98fcef99c50a816e6f0359b40b3ca434a6ef3e793850ca2315f9812848ca016e06
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libgfortran-16.1.0-1-any.pkg.tar.zst"
        SHA512 09e3490e0db1ebe045521a88c0fe98f9c62a45868ca7d18ff65f5d36da073dcfceed3a0eb9c6c05e12ab8e51f2dfef05db1d6c9b0000848c5a8a4f9cb6071bfa
        PROVIDES mingw-w64-x86_64-fc-libs
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libs-16.1.0-1-any.pkg.tar.zst"
        SHA512 6c5f3cbdcb3c93de29e66116bfb4371d033d0e80209c463cb075a9ae5e7f80b0bd4c204e8821d6e71e03554216e95699b0ebf41efe9e691167f7bc7730770c53
        PROVIDES mingw-w64-x86_64-omp mingw-w64-x86_64-cc-libs
        DEPS mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gettext-runtime-1.0-1-any.pkg.tar.zst"
        SHA512 83033ea38dec5b6e005a135468f583f7ab70e7081099901450fe605f7a63c2ec7ec71da7fdb50a052faa21df366e99b070a815a363edd647bea73bb270fa0190
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gmp-6.3.0-2-any.pkg.tar.zst"
        SHA512 38ab150051d787e44f1c75b3703d6c8deb429d244acb2a973ee232043b708e6c9e29a1f9e28f12e242c136d433e8eb5a5133a4d9ac7b87157a9749a8d215d2f0
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libffi-3.5.2-1-any.pkg.tar.zst"
        SHA512 75f4cb15257c362d760b3cd26b63ce65fdb91929ce7cf907c82ad04d9664da071df7740b5e92ad3c2bc091cf4d89626954a53f5ff35b0729ee279bee7aefc924
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.19-1-any.pkg.tar.zst"
        SHA512 ad5dc7df8314996ae1f0ca4254e53def331336912170df80b3d3c10e144b148f72697842469bb4cd0842a353fe9c766e016f670236c6ce85ecbd3348aced0dc1
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libsystre-1.0.2-2-any.pkg.tar.zst"
        SHA512 f042e762fa6f37017fedde3dfac5e4956e63e67d45bfcafeb83a125e5a76e970e9ab8a94de80a7b282bea3988948814d2d8d23fc768afb85eac1c1a4679d4f70
        PROVIDES mingw-w64-x86_64-libgnurx
        DEPS mingw-w64-x86_64-libtre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtasn1-4.21.0-1-any.pkg.tar.zst"
        SHA512 d09fc514e03eb04aff24f64d0efe75b11aa1104a51824148d026fed1fcf6eec2d40939585f3d4345a8d9ce340120563802cf828becfc7c8dcc95a5fa77c0ffdc
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtre-0.9.0-2-any.pkg.tar.zst"
        SHA512 e2ed8902c7a793ae71643c8063682beceb6f67ab8ad2781e50e6abee9ff9d6259ca5e3d94d7bbca3f011051e85912079576dfebffd1c8a584ef180658ee49e38
        DEPS mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwinpthread-14.0.0.r14.g4761eabdd-1-any.pkg.tar.zst"
        SHA512 690fde0a7370dd81da33505c2d572d6fef79d7d7f4c69fc1b958898a5e4c1f76696565a2c115c08eea1d3a225c5236b46aa45fbab7eafd649b7364f879667d36
        PROVIDES mingw-w64-x86_64-libwinpthread-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpc-1.4.1-1-any.pkg.tar.zst"
        SHA512 f50af1f29dbd617c1accd30f625197b5efdd56a820daeeeef5b04ccfc50bd58327065b181dbc2a95ade7607c40f2d592427281596db2554897ee6986f440946d
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ncurses-6.6-4-any.pkg.tar.zst"
        SHA512 04e3ab61264a999059bebbf39bd5933dd755d1e19d2312a5bc28c4889205d1df8cb4f9b5be34008e6fba333895369113016e9eb7d3d0d5a030c90dd6e18a5141
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-libsystre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openblas-0.3.33-1-any.pkg.tar.zst"
        SHA512 360a74f2071443396c79a02ef80e49de36715405011bf3cec19c10064a65cd4ba520d38def9e10471294397e35a9af17cfa3cd7cc103116cd5182d77ddfe8c4c
        DEPS mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-cc-libs mingw-w64-x86_64-omp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openssl-3.6.2-2-any.pkg.tar.zst"
        SHA512 bdc0c2bf5f0d58b3bef370b988b92ddf9390ae30b73645c98e0723094d6e446827c01fe2ee7d006fe72a68a484a01ee435f2d76aff97647d061af18f2f64472c
        #DEPS mingw-w64-x86_64-ca-certificates mingw-w64-x86_64-cc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-p11-kit-0.26.2-1-any.pkg.tar.zst"
        SHA512 056081ca24dddddba846481ddfb025a0f786281781dae2f265960e6622d4378f928d0f973092138da01b12b9f272fbd429b76d83d73590627a4d7b4036b50eca
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-libffi mingw-w64-x86_64-libtasn1
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-3.14.4-1-any.pkg.tar.zst"
        SHA512 5cf739c95345e2e2b193b6129ef7e56ad48cd6210db0d9161c0c34625f4f5cc4d99a61a438203037eed501d13eb9c5b33cdcdb4289f91ea06228f80afead10df
        PROVIDES mingw-w64-x86_64-python3 mingw-w64-x86_64-python3.12
        DEPS mingw-w64-x86_64-bzip2 mingw-w64-x86_64-expat mingw-w64-x86_64-cc-libs mingw-w64-x86_64-libffi mingw-w64-x86_64-mpdecimal mingw-w64-x86_64-ncurses mingw-w64-x86_64-openssl mingw-w64-x86_64-sqlite3 mingw-w64-x86_64-tcl mingw-w64-x86_64-tk mingw-w64-x86_64-xz mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-numpy-2.4.1-2-any.pkg.tar.zst"
        SHA512 579c353f733072ea231cc1e2d0b412ae40d9fe9e96415d389520a3861d2654d88112aba95669344d3b6827e29be9d7a241697c66727c16132d182c275881596b
        DEPS mingw-w64-x86_64-omp mingw-w64-x86_64-openblas mingw-w64-x86_64-python
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-readline-8.3.003-1-any.pkg.tar.zst"
        SHA512 4e504e5cd84d1be3c20b6472bf7fca6e224d78e054375ab0fbe645f2d0080a2955c9ee86a49bb7dfc3a20d9feaac396aa7a443fd211b41089088383faaae4f0b
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-termcap
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-sqlite3-3.53.0-2-any.pkg.tar.zst"
        SHA512 90aad03554f659f0e9a9e97791f766c00ba9d6dc2fcb857fd45279317ac14860e8ad16820a4a87071cde89dca643d2cc8d22b60cc7a518270635d292eb992dd8
        PROVIDES mingw-w64-x86_64-sqlite mingw-w64-x86_64-sqlite-analyzer
        DEPS mingw-w64-x86_64-readline mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-termcap-1.3.1-7-any.pkg.tar.zst"
        SHA512 2610355be441fd933f660f8181a5ad074057361a9aadeaad85961230dcf6df5d5165b94ccf9887144c91812485be57c2d79f39e8191ff525889bdff042d34ce6
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-tcl-8.6.17-1-any.pkg.tar.zst"
        SHA512 ed45b8077fc29368a9977bd699e5634c488ab3409d8e37872652086428b9706b3def7629d7bc5b3838d218e8633c83b8269c92b21977368d2ccdca232f67ca56
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-tk-8.6.17-2-any.pkg.tar.zst"
        SHA512 67fa5c5f71b8cb7679d53fb5854b05a5efedbd0c08e14c7c86a4e22256f94a70f90ccfdba085870256bb5bdcd6d2ce2e2fa20f89b5ce19da2ef31703203464c5
        DEPS mingw-w64-x86_64-tcl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-xz-5.8.3-1-any.pkg.tar.zst"
        SHA512 3148fc5f4280260568407c07bbfe61a5f76b53208ea0e0efa3fe4caae6b95e43a1dba2fa48793073cb7271b9d744ec4b94b16334b7fbca23195391ce381ddd57
        DEPS mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zlib-1.3.2-2-any.pkg.tar.zst"
        SHA512 8a32aec8c52f0ac607eb72d1fe432df22d09c72d88a5edb71d4f547eca1650549a1282ab9323a97ab0e8a99ffbd7590b34f852e0a7dec443174a512b9830de07
    )
endmacro()
