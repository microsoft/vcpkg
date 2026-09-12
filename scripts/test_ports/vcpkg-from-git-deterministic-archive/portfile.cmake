set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

function(z_vcpkg_from_git_deterministic_archive)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "OUT_SOURCE_PATH;URL;REF;HEAD_REF;SHA512" "PATCHES")
    
    vcpkg_from_git(
        OUT_SOURCE_PATH arg_OUT_SOURCE_PATH
        URL "${arg_URL}"
        REF "${arg_REF}"
        HEAD_REF "${arg_HEAD_REF}"
        PATCHES ${arg_PATCHES}
    )

    set(git_working_directory "${DOWNLOADS}/git-tmp")

    vcpkg_find_acquire_program(GIT)
    vcpkg_execute_required_process(
        COMMAND
            "${GIT}"
            -c core.autocrlf=false
            -c tar.umask=0022
            archive
            --format=tar
            --mtime=1970-01-01T00:00:00Z
            -o "${arg_OUT_SOURCE_PATH}.tar"
            "${arg_REF}^{tree}"
        WORKING_DIRECTORY "${git_working_directory}"
        LOGNAME "git-archive-${arg_REF}"
    )

    file(SHA512 "${arg_OUT_SOURCE_PATH}.tar" file_hash)
    if("${file_hash}" STREQUAL "${arg_SHA512}")
        message(STATUS "Using cached ${arg_OUT_SOURCE_PATH}.tar")
    else()
        message(FATAL_ERROR
            "  ${arg_OUT_SOURCE_PATH}.tar: error: z_vcpkg_from_git_deterministic_archive unexpected hash\n"
            "  Expected: ${arg_SHA512}\n"
            "  Actual  : ${file_hash}\n"
        )
    endif()
endfunction()

z_vcpkg_from_git_deterministic_archive(
    OUT_SOURCE_PATH JINJA2_OUT_SOURCE_PATH
    URL "https://chromium.googlesource.com/chromium/src/third_party/jinja2"
    REF c3027d884967773057bf74b957e3fea87e5df4d7
    HEAD_REF main
    SHA512 1726826092afb487b13c97dafdf4fd1c5cd9442bcfc82b72e0a54343dd7d857a9fc3a565e16c153c9520eb42f3c7f789d06674516b699a0516f0283bdfceba3c
)

z_vcpkg_from_git_deterministic_archive(
    OUT_SOURCE_PATH MARKUPSAFE_OUT_SOURCE_PATH
    URL "https://chromium.googlesource.com/chromium/src/third_party/markupsafe"
    REF 4256084ae14175d38a3ff7d739dca83ae49ccec6
    HEAD_REF main
    SHA512 d97ebf14a3712528ff37a4fff28a2d5f3a27544d93d9cef6165ca6442ae3ec78cb40613624533faf66cd6b08399f8cea160e6fc3f89766c88465ebc26c585d13
)

z_vcpkg_from_git_deterministic_archive(
    OUT_SOURCE_PATH DNG_OUT_SOURCE_PATH
    URL "https://android.googlesource.com/platform/external/dng_sdk"
    REF dbe0a676450d9b8c71bf00688bb306409b779e90
    HEAD_REF main
    SHA512 a7aeb448b413de7a8aa894e47d7249fdc3e2e5c8d6787cbbf7216c5b71195e2c4d41d358a1bc4088494425a8bc9a9f29e23087d8e7926425b5aa33bc015c3c3c
)

z_vcpkg_from_git_deterministic_archive(
    OUT_SOURCE_PATH PARTITION_ALLOCATOR_OUT_SOURCE_PATH
    URL "https://chromium.googlesource.com/chromium/src/base/allocator/partition_allocator"
    REF b8c0688f577c1bbce6c2c1ce4753cd685ca0f634
    HEAD_REF main
    SHA512 95d15ad037df20cf0ed2576b1e989bbc1338a25cce2ee6e0095d41affb13b7423917f8f11c1c5faed648fd4d4113fa80b92916906fcebe9cc120f169cd5f26a0
)

z_vcpkg_from_git_deterministic_archive(
    OUT_SOURCE_PATH PIEX_OUT_SOURCE_PATH
    URL "https://android.googlesource.com/platform/external/piex"
    REF eaddfa72c1693728db64101701431421371c38da
    HEAD_REF main
    SHA512 a97af8cfdde6c3a20b27bdb74a8259b17cbfb8bd61d31dcd2c5b18b948d30b4bff883d83284baf28b1e0877b48c8fe6f76c2d3d6c0de32ce75ad17206c93a308
)
