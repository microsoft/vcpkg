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

    z_vcpkg_download_distfile(msys_archive
        URLS ${all_urls}
        SHA512 "${arg_SHA512}"
        FILENAME "${arg_FILENAME}"
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
        DEPS bash sed autoconf2.73 autoconf2.72
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
        URL "https://mirror.msys2.org/msys/x86_64/bash-5.3.020-1-x86_64.pkg.tar.zst"
        SHA512 a0b1244c542d3afe0c15fba79eb41c9a606d5d60f8796320be8e2e31006ea860d13ffa46620de6d0b496fd7cdeef6d566f55341fdf84283148a8a85aa1e99552
        PROVIDES sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/binutils-2.47-1-x86_64.pkg.tar.zst"
        SHA512 a7b09b8835199b521dd8a09641d94eb0171fe393062ff8c97c63fd14b7ef492089586264a4b6c3d364039b5645e3a7799828e7c72e4a493f791511d8e67a91b0
        DEPS libiconv libintl zlib zstd
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
        URL "https://mirror.msys2.org/msys/x86_64/file-5.48-1-x86_64.pkg.tar.zst"
        SHA512 a44e90c23b768c10cf7efa4f4610a630508b1eba2f21e1f1e35082e751e5a710974cee278c3930a739411c8f3c50e8b8416be1f19531c0e4166ade63426fbb7d
        DEPS gcc-libs libbz2 liblzma libzstd zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/findutils-4.11.0-2-x86_64.pkg.tar.zst"
        SHA512 612f5c5780d819f7e1ba414d660063e96ee5aa31bd9ccbcbfb3896a5e062df0ff4b9a741cc14e381e5b1047a3d993c776aa645e2abad898a9b02d95a2424baf4
        DEPS libintl libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gawk-5.4.1-1-x86_64.pkg.tar.zst"
        SHA512 35ed345ec890fac920929bca26eade4edf1f409ae302371a24bbbf746712b62f16e05cfcf816ec13a42bfe2c2b75c46b922c0353b9665f5293dec65f13ed30bf
        PROVIDES awk
        DEPS libintl libreadline mpfr sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gcc-libs-15.3.0-1-x86_64.pkg.tar.zst"
        SHA512 49bfaaf4fb7417d29ca9e32bad19dfa85a303c82a948243c07fa6553c53b75a9504bb046468cafa156c701bfd76e9252b0861dead94afd1163bd55cbe52286bf
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
        URL "https://mirror.msys2.org/msys/x86_64/gzip-1.15-1-x86_64.pkg.tar.zst"
        SHA512 91a0139714d9a54e52263911073d27b6e614b314d21b0885bc6c49f402371ddec48fa352b2caec8ce3f7a889deabbb325cd057f8b9355a47f949775092cb1505
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
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libintl-0.22.5-1-x86_64.pkg.tar.zst"
        SHA512 1f1826763bcc252f15a0a5a27fbf596a2b5fad5e092bdff17af8231c373c0de17be7411938068aac0f0a617edbb32533de6619f6c58ebcdec7480c210673af45
        DEPS gcc-libs libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/liblzma-5.8.4-1-x86_64.pkg.tar.zst"
        SHA512 e4d72b3313e41aa386d7a7bfe92878a7f676ff2a2fea2d034493dd997de8c0aeeb44e952cd0544e5118d1cca4752a65aed6f0833470062fa88341c4b0bb83751
        # This package installs only a DLL. No extra deps.
        DEPS # gettext libiconv sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libpcre-8.45-5-x86_64.pkg.tar.zst"
        SHA512 3a0fffaf4d24bac07847220bac70b0e3f15645ea04171c5f4079966cbec01cee9138e36e5100b989af2dcce67660756c060fb3298c86fa120779c15d083231eb
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libreadline-8.3.006-1-x86_64.pkg.tar.zst"
        SHA512 87b322531d4e6ba14ffbf956bde79db5a8153fa103ef212ea3008d1813c7ad583c22547ed8984c184e8698215ccb1557d4cf1c24ea26ae45363556570b91bf36
        DEPS ncurses
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libtool-2.6.2-1-x86_64.pkg.tar.zst"
        SHA512 1d8f0fe447f5ac9cbef8c46097258cdc2d5b9052bbac23aa608f3d5378a55ac91575d3ea2efdc7f2b0cb3ce44b3500d44ffa59dd0d22476a5338aae919634007
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
        URL "https://mirror.msys2.org/msys/x86_64/make-4.4.1-3-x86_64.pkg.tar.zst"
        SHA512 52c08ceb977109570a97fe32a934a4bd27d471de4d7c53259cbdf9902706261bb771ebad9978d122f3498d1634d170da7ef378fd33592a4fec489a8710198677
        DEPS libintl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/mpfr-4.2.2-1-x86_64.pkg.tar.zst"
        SHA512 80fa09c637c4ff3943b20a5b74e945c7084e1f7d571d7124a5b45926533a24125a0027167f99eb9c1e9f96fc3d61344e23c0b4471815846d90367bcfb8f89eba
        DEPS gmp
    )
    if(X_VCPKG_USE_MSYS2_RUNTIME_3.4) # temporary option, for Windows 7.0 and 8.0, or in case of regressions
        z_vcpkg_acquire_msys_declare_package(
            URL "https://mirror.msys2.org/msys/x86_64/msys2-runtime-3.4-3.4.10-5-x86_64.pkg.tar.zst"
            SHA512 069fa1be3c7dafc2eb2d6a53af2782ef96eca2456a1e26024f52ec6ce21306bd4640d2caa301e8c6898a7ea85781ed67505c1f17cffc4e2f5114114047e4c10f
            PROVIDES msys2-runtime
        )
    else()
        z_vcpkg_acquire_msys_declare_package(
            URL "https://mirror.msys2.org/msys/x86_64/msys2-runtime-3.6.10-4-x86_64.pkg.tar.zst"
            SHA512 b0380c668456dbbcbee5695181be446357b9e1765a51cdf7140f247ccb06c37e064c79b17a0d50f3faa21eb13d08f228608ceb729a87c0862742e8b6161bc281
        )
    endif()
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/ncurses-6.6-2-x86_64.pkg.tar.zst"
        SHA512 a595a665ee7eedcced553902e48b5ed3240da60a7ca0a856dbe84cfba8bb1739629a55f1645ff9a44b77569646883ef125e2ed3c730b815e4b89e2df53dd6017
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/patch-2.8-2-x86_64.pkg.tar.zst"
        SHA512 876510f8f28b883deea6c81d0ab8e83b13972ee4d8e0f2799f9b64c2f7c3c753ba74db198a60c792601d720887b40273eca602025437fe43e76e4442abd9a1c9
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/perl-5.42.3-2-x86_64.pkg.tar.zst"
        SHA512 bcd6f682bf38f06ff291de6f8e03ea0e9fdb37bcee7ddf7ffbe273ad58d2e9eadb47a8b3a9c1be761f5f8a9b5d59369b5a2fd07037c5e408e646809bd9950886
        DEPS coreutils libxcrypt sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/pkgconf-3.0.7-1-x86_64.pkg.tar.zst"
        SHA512 8911e56f1a6acd34dd8e775f4a5d64cf09e05aa659d267acb79de3760157e5e64d2aecd61762da37e661142c348dce3d8cbad14a50ac958186abfcf74692b94c
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
        URL "https://mirror.msys2.org/msys/x86_64/which-2.25-1-x86_64.pkg.tar.zst"
        SHA512 f1a125152af4c377d638cc941434e8a7a519d24745aad28e7039f2ea93772e03540caea91d4ce832923d4927db5568ac8fd71911e7d71932b3edc3b315d8f53f
        DEPS sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/xz-5.8.4-1-x86_64.pkg.tar.zst"
        SHA512 e67dbe8273c4e36ac3087b9d534ca7e1a35157ac7c213f63baed99990df04b129200d71f054e346a0bab22da72c3d9004da7d27c7e29f96c4328ed988c63dbe7
        DEPS libiconv libintl liblzma
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/zlib-1.3.2-1-x86_64.pkg.tar.zst"
        SHA512 248de8c6181252afcdec15ca2ddc0079c5a71f9e153a10eae0e613e8c252ad6c7bd4f326c50dc94ba1d0725e2f93a00548ade86e0daf7156758332c555ad34a2
        DEPS gcc-libs
    )

    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/autoconf2.73-2.73-1-any.pkg.tar.zst"
        SHA512 e8253f3a03f4c06a74cc04cc965a985ffa5c26d804c499dbeb5ba7182855b0f75206173f3dc886dbdba3e8b3704aee72aa9b0c501da11000f824e4f786134151
        DEPS awk m4 diffutils bash perl sed
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/zstd-1.5.7-1-x86_64.pkg.tar.zst"
        SHA512 2f8e0bec670853c149c7123522420c32560731f882e7b15df36d9dca7a43ca2003d9ab1bea588429770a895a832ea61165dbdf410ceb4fac4165a9c427179a9b
        DEPS gcc-libs libzstd
    )

    # mingw64 subsystem
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-bzip2-1.0.8-4-any.pkg.tar.zst"
        SHA512 5fee7c1e9b76accb3830b13daee90b783f2d8f105d7904ca901b225e16bbfe71f97508b311fc72bdf234dbc752f857bbfe129531cca9e4b78a74c93121b17e73
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ca-certificates-20260816-1-any.pkg.tar.zst"
        SHA512 92e2c22c55ce22cb4107e163e622eab66d6e507bc202df81ea97d7c064fdba7e6f8396332080bace153e2b17edc4c2e593a691d2d76fd83cf7bfae3747031370
        DEPS mingw-w64-x86_64-p11-kit
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-expat-2.8.5-1-any.pkg.tar.zst"
        SHA512 0b42d34ac1720e0d8cea571d94c872d2e6b236cb52800d57725fa7f37fbb90ffaf0674612341955916fb199843b2a1c2257946f2d001a34ef9c381aa1e81ef85
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libgfortran-16.2.0-4-any.pkg.tar.zst"
        SHA512 378136bc1422b268c84d08f30b0b40f06c84a929c2c29dc1b7c89deb3a014f0030f404d4927f957e9b5042eb79f4f5e8c886510cfa67c8b2a4f967ffa6e4ee31
        PROVIDES mingw-w64-x86_64-fc-libs mingw-w64-x86_64-gcc-libgfortran
        DEPS mingw-w64-x86_64-libgcc mingw-w64-x86_64-libquadmath mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libs-16.2.0-4-any.pkg.tar.zst"
        SHA512 e2ededf22ff6b631aef5c220f2a7fc7e53479921fb1ceda202de466277509a4c6ec029fbe5b5f5c335b4ffaf4a5b0fc9f0e194d6808d044926dd1cd47241c1e8
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-libgomp
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libffi-3.8.0-1-any.pkg.tar.zst"
        SHA512 b836e74f107de7ceacab4b026f6ff21f7887782d18c90125427787fe98c7377d97b88a4cfe2818aa371798f5a2d96ad95724317ac81d60a117aa3e543cb598b8
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.19-1-any.pkg.tar.zst"
        SHA512 ad5dc7df8314996ae1f0ca4254e53def331336912170df80b3d3c10e144b148f72697842469bb4cd0842a353fe9c766e016f670236c6ce85ecbd3348aced0dc1
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libsystre-1.0.2-3-any.pkg.tar.zst"
        SHA512 27e1558030c4fe852c692450bcd7815336fa285468d4e2ee20b3c7ab01fac2602da88398b660e5ab41c655ab1f2968b676e586e288c43912d4dd37cd26322de2
        DEPS mingw-w64-x86_64-libtre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtasn1-4.21.0-1-any.pkg.tar.zst"
        SHA512 d09fc514e03eb04aff24f64d0efe75b11aa1104a51824148d026fed1fcf6eec2d40939585f3d4345a8d9ce340120563802cf828becfc7c8dcc95a5fa77c0ffdc
        DEPS mingw-w64-x86_64-cc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtre-0.9.0-2-any.pkg.tar.zst"
        SHA512 e2ed8902c7a793ae71643c8063682beceb6f67ab8ad2781e50e6abee9ff9d6259ca5e3d94d7bbca3f011051e85912079576dfebffd1c8a584ef180658ee49e38
        DEPS mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwinpthread-14.0.0.r426.g4564ee4b5-1-any.pkg.tar.zst"
        SHA512 dece3323f8c4a7de03fbc0d66be42bf64177af26a176a91463d2bf28377e460b831df3c39c9ecbe180bd36a79f41bbdeb35a9dc60a78b674e850f5309325a93c
        PROVIDES mingw-w64-x86_64-libwinpthread-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpc-1.4.1-1-any.pkg.tar.zst"
        SHA512 f50af1f29dbd617c1accd30f625197b5efdd56a820daeeeef5b04ccfc50bd58327065b181dbc2a95ade7607c40f2d592427281596db2554897ee6986f440946d
        DEPS mingw-w64-x86_64-gmp mingw-w64-x86_64-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpdecimal-4.0.1-3-any.pkg.tar.zst"
        SHA512 eb6eba753d58aef296b2c05759f6df5733e9e1e667583fb52c9e7c6387ede9a617ac2940efc525af739c0884c45b32289d0474727fe156d35b226c2518a1f30b
        DEPS mingw-w64-x86_64-cc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpfr-4.2.2-3-any.pkg.tar.zst"
        SHA512 d8f45cc639b0fd9ece1836f824bf9769ab97b4cf1c54ebd88fff6c9e4b2c0209e27300b6e8707c7f40a6f40ca1a67c3190a37f9f6b9f97dd0b2e9187d24fb61c
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ncurses-6.6-4-any.pkg.tar.zst"
        SHA512 04e3ab61264a999059bebbf39bd5933dd755d1e19d2312a5bc28c4889205d1df8cb4f9b5be34008e6fba333895369113016e9eb7d3d0d5a030c90dd6e18a5141
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-pcre2 mingw-w64-x86_64-libsystre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openblas-0.3.34-1-any.pkg.tar.zst"
        SHA512 8356d5f5138e00314b187df6609b7a82f1f7ab015ff8cc7b8560e4c0bf556540247a636745ef7997027649f0864d35a3de9b1761683dd7da18125326fe82c229
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-fc-libs mingw-w64-x86_64-omp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openssl-3.6.4-1-any.pkg.tar.zst"
        SHA512 99d23b6661a16192470dd74999d4b042b3c7747396bfc5632340201087f4a91fbc1c0d1246f7fe51df1fdd885b5665836c4a11a5f045b2e3562b64bf42908159
        #DEPS mingw-w64-x86_64-ca-certificates mingw-w64-x86_64-cc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-p11-kit-0.26.5-1-any.pkg.tar.zst"
        SHA512 8e805fe74de641a11886f7f6fa959f1c9bf981282518a96e9bc839fd51b8728b7f2861966b3c842376a71065ee94673c0c8e36fcaed3f48671c8e79199dc37a6
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-libffi mingw-w64-x86_64-libtasn1
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-3.14.7-1-any.pkg.tar.zst"
        SHA512 4ab9fe31419c9a2cafcf95bc9e6b034a7797bd7193180af133c64a510c2835934e9256579e3445d3e26c71f8155752e95b9161b3f5e6e9a0f484e773b2fc0f52
        PROVIDES mingw-w64-x86_64-python3 mingw-w64-x86_64-python3.14
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-expat mingw-w64-x86_64-bzip2 mingw-w64-x86_64-libffi mingw-w64-x86_64-mpdecimal mingw-w64-x86_64-ncurses mingw-w64-x86_64-openssl mingw-w64-x86_64-sqlite3 mingw-w64-x86_64-tcl mingw-w64-x86_64-tk mingw-w64-x86_64-zlib mingw-w64-x86_64-libb2 mingw-w64-x86_64-xz
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-numpy-2.5.3-1-any.pkg.tar.zst"
        SHA512 1319095a01ac9abc4295e0e3d8d63d3eee9d614999f109b129c66ffece099ebd69584ff32522622ef0394d3b4f4e5d96e8df3dbd6612964ef62ebccd47c4b612
        DEPS mingw-w64-x86_64-omp mingw-w64-x86_64-openblas mingw-w64-x86_64-python
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-readline-8.3.003-1-any.pkg.tar.zst"
        SHA512 4e504e5cd84d1be3c20b6472bf7fca6e224d78e054375ab0fbe645f2d0080a2955c9ee86a49bb7dfc3a20d9feaac396aa7a443fd211b41089088383faaae4f0b
        DEPS mingw-w64-x86_64-cc-libs mingw-w64-x86_64-termcap
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-sqlite3-3.53.4-1-any.pkg.tar.zst"
        SHA512 0e14dff6800baff1560e3cd037ee0febdae869edfa8ba9cc246700057eef2f28a32e0b04f70974929a1c11a80dce8518c64b10e90287702162faf32db9414b99
        PROVIDES mingw-w64-x86_64-sqlite mingw-w64-x86_64-sqlite-analyzer
        DEPS mingw-w64-x86_64-tcl mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-termcap-1.3.1-7-any.pkg.tar.zst"
        SHA512 2610355be441fd933f660f8181a5ad074057361a9aadeaad85961230dcf6df5d5165b94ccf9887144c91812485be57c2d79f39e8191ff525889bdff042d34ce6
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-tcl-8.6.18-1-any.pkg.tar.zst"
        SHA512 27cfe4f5930f2ed920e34d76c3d81313fe76d232986b913147c40fd9c2253cfa65efa60bfcd25a0b37f5fdf8815763303a3179d2baaed15255691424bddb5ebe
        DEPS mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-tk-8.6.18-1-any.pkg.tar.zst"
        SHA512 810b1ae68153604d33afbf9b8a9ec08645fecfc02b9f159a8ce20ba1bd27551496d74f9bfea5efc68d860f950cfa722700f3f87f0b1c027d6d6e0206fa1bc6cf
        DEPS mingw-w64-x86_64-tcl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-xz-5.8.4-1-any.pkg.tar.zst"
        SHA512 6449206d11c79b5142728379ea497a2c59ebcbaaa8ee9151562a1ce4dad9ddccaddbb1e66dccfff087b977576968012c1a0a04015fd470c3ae29d514f9d72cc6
        DEPS mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zlib-1.3.2-2-any.pkg.tar.zst"
        SHA512 8a32aec8c52f0ac607eb72d1fe432df22d09c72d88a5edb71d4f547eca1650549a1282ab9323a97ab0e8a99ffbd7590b34f852e0a7dec443174a512b9830de07
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-cc-libs-16.2.0-4-any.pkg.tar.zst"
        SHA512 6c7f4186e3434021937c99b3a7b24ecbd4d6a2f2b7ce04c0331eb16557169b97bee061f9c6b685787623779600de9ba0b19ec4454dbfd4354dc3b4a9060a2c8e
        DEPS mingw-w64-x86_64-libatomic mingw-w64-x86_64-libgcc mingw-w64-x86_64-libstdc++ mingw-w64-x86_64-libquadmath
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libb2-0.98.1-3-any.pkg.tar.zst"
        SHA512 ec3c244889c76e6f6bf34d97e229a66dd429474235184154047a4586c58d54f85032e7022176a72389877a3e07db0dd2d8ca356254ac6274f87e4940fe759d7c
        DEPS mingw-w64-x86_64-cc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libgcc-16.2.0-4-any.pkg.tar.zst"
        SHA512 0cfaa54646d8e206db6484bf5dd9d411fd052102b41385b24a60d6ec53a17325f2d075bba03395bd3d0a737de92c2fe9b014824ee9352feb59ca116386eb28ab
        DEPS mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libgomp-16.2.0-4-any.pkg.tar.zst"
        SHA512 c9cce8abfb3635b27e285f2218dcf8123bf38113bfc79a60eb3ad0c70bdd4d65b3c91006a25aed6b5ea2a5e55609d4e71f13a59d58a97a9b3887da6662b12c51
        PROVIDES mingw-w64-x86_64-omp
        DEPS mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libquadmath-16.2.0-4-any.pkg.tar.zst"
        SHA512 2a3eb11259051819762b84db9d2f437af8ad2d36e71327955c23c09ace2e509e95f0d9f7f8faa3ca3878fd000dd765a610e15bacad76bb10744b5f9cf2d22dfb
        DEPS mingw-w64-x86_64-libgcc
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libstdc++-16.2.0-4-any.pkg.tar.zst"
        SHA512 68276cd5032044e3d615ee13b72fba263b2253bc7cd45f2d33fe7cee592efa88a1e1ffef17e14ecc7ed5810f2452150d7ab8c32ef8589ae34aec6654c077ac9e
        DEPS mingw-w64-x86_64-libgcc mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-pcre2-10.48-3-any.pkg.tar.zst"
        SHA512 ff4c833ff9ae29f6bcee0d45035bcc4df82b12d006b616d5ee1264584239bf3d31442bf38b41bf3c47964bb4dc1a3e0bb31982b7c5a4c68628076d59ad5b9746
        DEPS mingw-w64-x86_64-bzip2 mingw-w64-x86_64-wineditline mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libatomic-16.2.0-4-any.pkg.tar.zst"
        SHA512 1e4aaef6f4398fb313b462068227cce7b51696f1b5b712eff4c35e5c93d24265be0653543783a071ab5c971d2d3d6cd97ab5136c9d7b408906e15468d3a4fef2
        DEPS mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-wineditline-2.208-1-any.pkg.tar.zst"
        SHA512 9fb577234cf327d949c69c6e38f980b16dacb15e12b3d3d37fd84e69d2ecae8d24ba29ac1e0a351f69e4c7eff5f6ff4518a298a6f0c99e8f685c37e173d7097c
    )
endmacro()
