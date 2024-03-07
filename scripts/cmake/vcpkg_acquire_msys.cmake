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
        URL "https://mirror.msys2.org/msys/x86_64/autoconf-wrapper-20221207-1-any.pkg.tar.zst"
        SHA512 601ceb483ddf49d744ed7e365317d64777752e35010a1087082452afd42d8d29fc5331cb3fa4654eb09eec85416c8c5b70fed91a45acfaa667f06f80e6d42f30
        PROVIDES autoconf
        DEPS autoconf2.71 bash sed
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/autoconf2.71-2.71-3-any.pkg.tar.zst"
        SHA512 dd312c428b2e19afd00899eb53ea4255794dea4c19d1d6dea2419cb6a54209ea2130d48abbc20af12196b9f628143436f736fbf889809c2c2291be0c69c0e306
        DEPS awk bash diffutils m4 perl sed
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/autoconf-archive-2023.02.20-1-any.pkg.tar.zst"
        SHA512 0dbdba67934402eeb974e6738eb9857d013342b4e3a11200710b87fbf085d5bebf49b29b6a14b6ff2511b126549919a375b68f19cc22aa18f6ba23c57290ac72
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/automake-wrapper-20221207-2-any.pkg.tar.zst"
        SHA512 4351c607edcf00df055b1310a790e41a63c575fbd80a6888d3693b88cad31d4628f9b96f849e319089893c826cf4473d9b31206d7ccb4cea15fd05b6b0ccb582
        PROVIDES automake
        DEPS automake1.16 bash gawk
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/automake1.16-1.16.5-1-any.pkg.tar.zst"
        SHA512 62c9dfe28d6f1d60310f49319723862d29fc1a49f7be82513a4bf1e2187ecd4023086faf9914ddb6701c7c1e066ac852c0209db2c058f3865910035372a4840a
        DEPS bash perl
        PATCHES "${Z_VCPKG_AUTOMAKE_CLANG_CL_PATCH}"
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/bash-5.2.026-1-x86_64.pkg.tar.zst"
        SHA512 f69046b27b0ecec6afc60b3ba107491c50c70f6f41b989fe6fcc58da798345cb8336ff6cc668bc13ee49ff24d3be4b5932bc8fe87e80da4e6243063c18f0dcf8
        PROVIDES sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/binutils-2.42-1-x86_64.pkg.tar.zst"
        SHA512 6e12fbb6e7a14bac5cf3665d0e9867d40ef47ba76d4887748671e46e9ea288dbfc59b40461e6552559aa24651a057c18c022d2f24d679edfc42d8ca7e43af28d
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
        URL "https://mirror.msys2.org/msys/x86_64/file-5.45-1-x86_64.pkg.tar.zst"
        SHA512 fae01c7e2c88357be024aa09dba7b805d596cec7cde5c29a46c3ab209c67de64a005887e346edaad84b5173c033cb6618997d864f7fad4a7555bd38a3f7831c5
        DEPS gcc-libs libbz2 liblzma libzstd zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/findutils-4.9.0-3-x86_64.pkg.tar.zst"
        SHA512 1538733929ecc11bc7c19797577e4cd59cc88499b375e3c2ea4a8ed4d66a1a02f4468ff916046c76195ba92f4c591d0e351371768117a423595d2e43b3321aad
        DEPS libintl libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gawk-5.3.0-1-x86_64.pkg.tar.zst"
        SHA512 01a65153ffa109c51f05ef014534feecde9fc3e83ab4f5fc7f0ae957ea8a0bad2756fc65a86e20ab87a063c92161f7a7fccc8232b51c44c6ee506b7cff3762e7
        PROVIDES awk
        DEPS libintl libreadline mpfr sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/gcc-libs-13.2.0-2-x86_64.pkg.tar.zst" # 05-Jul-2022
        SHA512 0bf8d56516ed7f14db2d1a991ccced0977d33a560f1844b114b62b2cd93d96374d3b85c5257adc0c4f141c3f3533bc4e8914349547092d607c22dea3bdbbbd0d
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
        URL "https://mirror.msys2.org/msys/x86_64/liblzma-5.4.6-2-x86_64.pkg.tar.zst"
        SHA512 d79bf6089f258e17226b30c1d68ee7b391048174386d366007f2361f2db0dc069a056549f483ac62285db238d9812d801bc347684ab485058d55cad16ce36dc0
        # This package installs only a DLL. No extra deps.
        DEPS # gettext libiconv sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libpcre-8.45-4-x86_64.pkg.tar.zst"
        SHA512 e1eb5cb38dce22012527bba2e92f908bf23c7725d77dcbd7fa14597af0f5b413319e0a7dd66555370afffc3b55d6074b8b83fd3c384d31ac505b74db246d54ac
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libreadline-8.2.010-1-x86_64.pkg.tar.zst"
        SHA512 ce5e4b4abd347a2e8d4a48860aca062b0478000b3696859d0e143643f16b845bc0e7c84bf4fbf95cbcc043a6acebe2d28acc65b763d2de6a95f13ab6b3a3649f
        DEPS ncurses
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/libtool-2.4.7-3-x86_64.pkg.tar.zst"
        SHA512 a202ddaefa93d8a4b15431dc514e3a6200c47275c5a0027c09cc32b28bc079b1b9a93d5ef65adafdc9aba5f76a42f3303b1492106ddf72e67f1801ebfe6d02cc
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
        URL "https://mirror.msys2.org/msys/x86_64/libzstd-1.5.5-1-x86_64.pkg.tar.zst"
        SHA512 c3d491f90bef0cbd7447303ff6f5a647e9fcf7bb0af9116cfe5fe421180e2283ec9403c768caa9434e9b158ce6ebde1a4750c56db8f67dfac4d6282d0ac30413
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/m4-1.4.19-2-x86_64.pkg.tar.zst"
        SHA512 7471099ba7e3b47e5b019dc0e563165a8660722f2bbd337fb579e6d1832c0e7dcab0ca9297c4692b18add92c4ad49e94391c621cf38874e2ff63d4f926bac38c
        DEPS bash gcc-libs libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/make-4.4.1-1-x86_64.pkg.tar.zst"
        SHA512 7e1c95b976d949db4b74c444e0d1495bbee26649aa82eadf34076dba3c1223d4e7b901e07935ba73dceda67f0a0cf25dd99fe3eed5300a5163fdaab14ca8d9fc
        DEPS libintl sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/mpfr-4.2.1-1-x86_64.pkg.tar.zst"
        SHA512 7417bb02a0f1073b8c1a64732463ec178d28f75eebd9621d02117cda1d214aff3e28277bd20e1e4731e191daab26e38333ace007ed44459ce3e2feae27aedc00
        DEPS gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/msys2-runtime-3.4.10-4-x86_64.pkg.tar.zst"
        SHA512 b921b59b840dc2813825917dcff0c3686658f9af556bdb95b536fcb949d593886c9815e4bff136472797218e1f0462fbc49f87f2a31ec9abb2407c5506807f88
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/ncurses-6.4-2-x86_64.pkg.tar.zst"
        SHA512 31d1e75071158aae970209de79adc3b3ff1d189ffc18460b3f1c818784e571ff3e0ff2767013516f9bb3fd0e62c2038444f1e8c1816db357d57e31f8663f4420
        DEPS gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/patch-2.7.6-2-x86_64.pkg.tar.zst"
        SHA512 eb484156e6e93da061645437859531f7b04abe6fef9973027343302f088a8681d413d87c5635a10b61ddc4a3e4d537af1de7552b3a13106639e451b95831ec91
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/perl-5.38.2-1-x86_64.pkg.tar.zst"
        SHA512 00c992e0fd8847f579dd33a82140034c6a81b650f456d2b22706f82c5c6db04dce4f1194024775081ae7bffa01afc476df1815ec7cc98ebb0a676726a0c1c2b2
        DEPS coreutils libxcrypt sh
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/msys/x86_64/pkgconf-2.1.0-1-x86_64.pkg.tar.zst"
        SHA512 4376aba6fd2c118b1cb7e2008a23724aae62e9c972849b984a087079eaff1a29f423d3dedc3d7cfa682d931eb9a72891c8630196507a4a2cbe15f80a359bfa58
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
        URL "https://mirror.msys2.org/msys/x86_64/texinfo-7.1-2-x86_64.pkg.tar.zst"
        SHA512 10edea1d3e2720afd47f0ff77ba47849b3eaf5d62d6025c3bce1d683302ae11126e7ee7b26751d1a6a66bc86a4c09021feb373434b1808441897e02245235c7b
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
        URL "https://mirror.msys2.org/msys/x86_64/xz-5.4.6-2-x86_64.pkg.tar.zst"
        SHA512 301e612ce0174b1d80a0e40c96f6bc2941c57f5e2a6c0e8e05b9d479cc000204d0df364c0a4df6eeb923107bee3e8f20cbef35825a2eec3e489c525ce2605534
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ca-certificates-20230311-1-any.pkg.tar.zst"
        SHA512 f7526ad35bccc5edba3fcf1354a85eacbd61dba5780b1bc65c7e8795ecb252432004af809052bb0ba981b1dea174c40e2d3f20655d8e2b29be95ad54d2aa5782
        DEPS mingw-w64-x86_64-p11-kit
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-expat-2.5.0-1-any.pkg.tar.zst"
        SHA512 b49ec84750387af5b73a78d654673d62cf0e2cb2b59b4d25acb7eca3830018f7a2aefe600d67d843417cfbdd97db81ecfd49a8811e312f53b42c21fb106b230d
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libgfortran-13.2.0-3-any.pkg.tar.zst"
        SHA512 da0902979b2fd1a556d639587caeb24a756bdab29f6179fdb2deac3463bb7c150f13db6b944da2a7ade69d496199b7e8bd22ec1515beb26fab1a01e3b4e6c2bd
        PROVIDES mingw-w64-x86_64-fc-libs
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libs-13.2.0-3-any.pkg.tar.zst"
        SHA512 f904ee75196ab63df4b63b84f08bfd5956a178c72fea21fdcf8727f7d70f538b358a546316c4542c36a5c3169f88437426c785ac8e2a99d8eb952be7429216d4
        PROVIDES mingw-w64-x86_64-omp
        DEPS mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gettext-runtime-0.22.4-5-any.pkg.tar.zst"
        SHA512 03a0210dd2c57a282e8de6a96d871cf8957b16a88464f62fa0cbf42e6ccf60046ce2ff7fcabd086775893f7ade92bb9f9bf5740e92aba6efbdc2aea3ece35c73
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gmp-6.3.0-2-any.pkg.tar.zst"
        SHA512 38ab150051d787e44f1c75b3703d6c8deb429d244acb2a973ee232043b708e6c9e29a1f9e28f12e242c136d433e8eb5a5133a4d9ac7b87157a9749a8d215d2f0
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libffi-3.4.4-1-any.pkg.tar.zst"
        SHA512 ec88a0e0cb9b3ff3879d3fd952d3ad52f0d86a42669eddaeca47778ab0d5213abdea7d480a23aa3870e08d6b93b9c4988855e368474be7186e9719456baae5df
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.17-4-any.pkg.tar.zst"
        SHA512 dc703b103291a5b89175c3ddf4282c1a40bcd91549c8f993300671b9afffb28559e118a2c665f47a465bd7286b9e3400c29d42761e0189c425fb156b37783927
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libsystre-1.0.1-5-any.pkg.tar.zst"
        SHA512 10ea2bacebb8b05c642f34c0ecf61710b9f1906615851825d1104d0e25b1a911f7541a3068b97de2eb71aa13d6963f61c7fdf051c5582e0868a6f90b93f7aa77
        PROVIDES mingw-w64-x86_64-libgnurx
        DEPS mingw-w64-x86_64-libtre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtasn1-4.19.0-1-any.pkg.tar.zst"
        SHA512 761a7c316914d7f98ec6489fb4c06d227e5956d50f2e233ad9be119cfd6301f6b7e4f872316c0bae3913268c1aa9b224b172ab94130489fbd5d7269ff9064cfb
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtre-git-r177.07e66d0-2-any.pkg.tar.zst"
        SHA512 a21a03fd446707f748f4101e723f71d5f2c93c736d86205dc9eee6681d1bb1248283b8921f897391b56143d8dcf6be29cf8c2c57abcf32e1e4d0b2ea2309a790
        PROVIDES mingw-w64-x86_64-libtre
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwinpthread-git-11.0.0.r551.g86a5e0f41-1-any.pkg.tar.zst"
        SHA512 2742d5939e6f677d148f0f07ddc399bf8e4bf3c07f9b90160f20314f1c69e549b9f9d6cbf0df35d7f950d2e09e57c56c0496475cb66f053dcf0bcfdf3bb14bb1
        PROVIDES mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpc-1.3.1-2-any.pkg.tar.zst"
        SHA512 3fe183d4af3b3935a4394502eab75a8f7b7692f551fd44e54c67935a4691388d23a021ee1147f0345ed27ffe8a8db3e9e7e37caf2348df3413e0acd519c12a0c
        DEPS mingw-w64-x86_64-gmp mingw-w64-x86_64-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpdecimal-2.5.1-1-any.pkg.tar.zst"
        SHA512 1204c31367f9268ffd6658be04af7687c01f984c9d6be8c7a20ee0ebde1ca9a03b766ef1aeb1fa7aaa97b88a57f7a73afa7f7a7fed9c6b895a032db11e6133bf
        DEPS mingw-w64-x86_64-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpfr-4.2.1-2-any.pkg.tar.zst"
        SHA512 03a727e1622b09ed0b6e0cb93a6b1040c31c9504c3f14bd1a2e12b8293153609796bc99882393b343c4d96e45f402f847317a3a65212b972ff96a964e5e52815
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ncurses-6.4.20231217-1-any.pkg.tar.zst"
        SHA512 54a936731589a1af653dc73da983b683e8fc687e9c3737f5215acdef70e3596cddce44d01a6e98e482fd3f071da20cd5ab10b54d52cbdc0b34bbdc090a1cf3d3
        DEPS mingw-w64-x86_64-libsystre
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openblas-0.3.26-1-any.pkg.tar.zst"
        SHA512 de5b2b3eca6976a26dded23d5be6f1cdccb68e4a41a3568f917f78aee2bc9c91b5ff7e566cbc2fa9d6852c57b90bb92a36b95efe458c88f1819961a27d91129b
        PROVIDES mingw-w64-x86_64-OpenBLAS
        DEPS mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-omp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-openssl-3.2.1-1-any.pkg.tar.zst"
        SHA512 706218c8d7321358cf7f1c472c89c19f88245eeff5037712b2a64c9f81166bcd7b2a06cc3343af5a75a65c520890d845d8d1234feddbe622992b6e9825e81f5c
        #DEPS mingw-w64-x86_64-ca-certificates mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-p11-kit-0.25.3-2-any.pkg.tar.zst"
        SHA512 81e62ad4b1bdf7da3b2de20a3a444b2a30a7b38dda8df41ca7e8baed0954a335cc9594ddd577f4ea5b6000d945348dc7d0364c9408e8a3e3afef34cc5c083c85
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-libffi mingw-w64-x86_64-libtasn1
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-3.11.7-1-any.pkg.tar.zst"
        SHA512 f94e2e53887da29bdcdafd4ad86d709e98c1bd271fdf9c5a85904cf20eae7690b8efef5b858a8bc979f6106343cec6ab6a828fcad631e4c30ce89c736603375e
        PROVIDES mingw-w64-x86_64-python3 mingw-w64-x86_64-python3.11
        DEPS mingw-w64-x86_64-bzip2 mingw-w64-x86_64-expat mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-libffi mingw-w64-x86_64-mpdecimal mingw-w64-x86_64-ncurses mingw-w64-x86_64-openssl mingw-w64-x86_64-sqlite3 mingw-w64-x86_64-tcl mingw-w64-x86_64-tk mingw-w64-x86_64-xz mingw-w64-x86_64-zlib
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python-numpy-1.26.3-1-any.pkg.tar.zst"
        SHA512 62fac7ca3c936bc42902652933373420fb422fb49bfe808e4a4d71183983c5d386f88c1772e6e07477c5b76f5fd489ef5084bef33588c3db63edccaa361520d2
        PROVIDES mingw-w64-x86_64-python3-numpy
        DEPS mingw-w64-x86_64-openblas mingw-w64-x86_64-python
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-readline-8.2.010-1-any.pkg.tar.zst"
        SHA512 ade6caf9e97e762cb2a129a838e1b73e4a2cc4488a7db5c1b6a3ec5db7206d9108a9a7fc5e0e6d7099f26d15ddf71238006dd09467ad2a7617ad9dd925ea04e2
        DEPS mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-termcap
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-sqlite3-3.45.1-1-any.pkg.tar.zst"
        SHA512 b54ae774fc82f83a19a78910cc068597f85fbd798d52c518fee24030043b606986f235ed86f99879d8de3360c2cbaf53500108a3db8638da1f32096d9439e90f
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-tk-8.6.12-2-any.pkg.tar.zst"
        SHA512 832c98f2bb8963540d175bc6511f00747483d86b0e0d3219c7b6e5b0bd5e7d038018db08875bf26b3fbe6082b4ff1958777e5cfd1920f5d235493f0a1ce071b2
        DEPS mingw-w64-x86_64-tcl
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-xz-5.4.6-2-any.pkg.tar.zst"
        SHA512 4ca1f3707003d43bdf5c6e7df1d0ea2a9ea56acfaa8a1b8db89f76d97ac8eb709b8af4d4233da412fdec3bffb72f7809462356d2afe61675bce8d2b23a7ce1d6
        DEPS mingw-w64-x86_64-gettext-runtime
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zlib-1.3.1-1-any.pkg.tar.zst"
        SHA512 1336cd0db102af495d8bbfc6a1956f365750b19d2377fe809e9b26f61a8a6600394e7343677645c5743f4974161535dad5c0503ff50f6126d27bb927754e7320
    )
endmacro()
