include_guard(GLOBAL)

# Looks like Rust doesn't have any mirrors
set(Z_VCPKG_ACQUIRE_RUST_MIRRORS
    "https://static.rust-lang.org/"
)

function(z_vcpkg_rust_acquire_download_package out_archive)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "URL;SHA512;FILENAME" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "internal error: z_vcpkg_rust_acquire_download_package passed extra args: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(all_urls "${arg_URL}")

    foreach(mirror IN LISTS Z_VCPKG_ACQUIRE_RUST_MIRRORS)
        string(REPLACE "https://static.rust-lang.org/" "${mirror}" mirror_url "${arg_URL}")
        list(APPEND all_urls "${mirror_url}")
    endforeach()

    vcpkg_download_distfile(rust_archive
        URLS ${all_urls}
        SHA512 "${arg_SHA512}"
        FILENAME "rust-${arg_FILENAME}"
        QUIET
    )
    set("${out_archive}" "${rust_archive}" PARENT_SCOPE)
endfunction()

# writes to the following variables in parent scope:
#   - Z_VCPKG_RUST_ARCHIVES
#   - Z_VCPKG_RUST_TOTAL_HASH
#   - Z_VCPKG_RUST_PACKAGES
#   - Z_VCPKG_RUST_${arg_NAME}_ARCHIVE
#   - Z_VCPKG_RUST_${arg_NAME}_PATCHES
function(z_vcpkg_rust_acquire_declare_package)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "NAME;ARCH;PLATFORM;URL;SHA512;DIRECTORY" "DEPS")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "internal error: z_vcpkg_rust_acquire_declare_package passed extra args: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(required_arg IN ITEMS URL SHA512)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "internal error: z_vcpkg_rust_acquire_declare_package requires argument: ${required_arg}")
        endif()
    endforeach()

    if(NOT arg_URL MATCHES [[^https://static.rust-lang.org/dist/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/(([a-z_-]+)-([0-9]+\.[0-9]+\.[0-9])-(aarch64|arm|armv7|i686|mips|mips64|mips64el|mipsel|powerpc|powerpc64|powerpc64le|riscv64gc|s390x|x86_64)-([a-z0-9_-]+)\.tar\.xz)$]])
        message(FATAL_ERROR "internal error: regex does not match supplied URL to vcpkg_rust_acquire: ${arg_URL}")
    endif()

    set(filename "${CMAKE_MATCH_1}")
    if(NOT DEFINED arg_NAME)
        set(arg_NAME "${CMAKE_MATCH_2}")
    endif()

    if(NOT DEFINED arg_ARCH)
        if("${CMAKE_MATCH_4}" STREQUAL "x86_64")
            set(arg_ARCH "x64")
        elseif("${CMAKE_MATCH_4}" STREQUAL "i686")
            set(arg_ARCH "x86")
        else()
            message(FATAL_ERROR "internal error: Can't match architecture '${CMAKE_MATCH_4}' to vcpkg architecture")    
        endif()
    endif()

    if(NOT DEFINED arg_PLATFORM)
        if("${CMAKE_MATCH_5}" STREQUAL "pc-windows-msvc")
            set(arg_PLATFORM "windows")
		elseif("${CMAKE_MATCH_5}" STREQUAL "unknown-linux-gnu")
			set(arg_PLATFORM "linux")
        else()
            message(FATAL_ERROR "internal error: Can't match platform '${CMAKE_MATCH_5}' to vcpkg platform")
        endif()
    endif()

    # If the package doesn't match the host triplet, bail here
    if(NOT HOST_TRIPLET MATCHES "^${arg_ARCH}-${arg_PLATFORM}.*$")
        return()
    endif()

    if("${arg_NAME}" IN_LIST Z_VCPKG_RUST_PACKAGES OR arg_Z_ALL_PACKAGES)
        list(REMOVE_ITEM Z_VCPKG_RUST_PACKAGES "${arg_NAME}")
        list(APPEND Z_VCPKG_RUST_PACKAGES ${arg_DEPS})
        set(Z_VCPKG_RUST_PACKAGES "${Z_VCPKG_RUST_PACKAGES}" PARENT_SCOPE)

        z_vcpkg_rust_acquire_download_package(archive
            URL "${arg_URL}"
            SHA512 "${arg_SHA512}"
            FILENAME "${filename}"
        )

        list(APPEND Z_VCPKG_RUST_ARCHIVES "${arg_NAME}")
        set(Z_VCPKG_RUST_ARCHIVES "${Z_VCPKG_RUST_ARCHIVES}" PARENT_SCOPE)
        set(Z_VCPKG_RUST_${arg_NAME}_ARCHIVE "${archive}" PARENT_SCOPE)
        set(Z_VCPKG_RUST_${arg_NAME}_PATCHES "${arg_PATCHES}" PARENT_SCOPE)
        string(APPEND Z_VCPKG_RUST_TOTAL_HASH "${arg_SHA512}")
        set(Z_VCPKG_RUST_TOTAL_HASH "${Z_VCPKG_RUST_TOTAL_HASH}" PARENT_SCOPE)
    endif()
endfunction()

function(z_vcpkg_rust_install_packages out_rust_root)
    cmake_parse_arguments(PARSE_ARGV 1 "arg"
        "NO_DEFAULT_PACKAGES;Z_ALL_PACKAGES"
        ""
        "PACKAGES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_rust_acquire was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(Z_VCPKG_RUST_TOTAL_HASH "")
    set(Z_VCPKG_RUST_ARCHIVES "")

    set(Z_VCPKG_RUST_PACKAGES "${arg_PACKAGES}")

    if(NOT arg_NO_DEFAULT_PACKAGES)
        list(APPEND Z_VCPKG_RUST_PACKAGES rustc rust-std cargo)
    endif()

    # i686-pc-windows-msvc
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/rustc-1.68.2-i686-pc-windows-msvc.tar.xz"
        SHA512 7f95fd9cf2a5e4cef4acf299f4b30959817a82c3edd2c4d05b6cc641630a20d217b108760d1283b61cebb21fd4ddca284a8b8ae96d0968df2e39409407150b95
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/rust-std-1.68.2-i686-pc-windows-msvc.tar.xz"
        SHA512 4eca92bf48081443210eb94fca01c452a903be498a413306dce6cf04e66524580d37d595190612e2161ec38c50afe8ccc16f8e2816fe126ab5a36a2508751603
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/cargo-1.68.2-i686-pc-windows-msvc.tar.xz"
        SHA512 b433845ab706fd842a1766b9f32f83352f19cc078b4fb5e200aefb5c55bde13ddd41670ee16074644376bc75689e4de3ce5e822e4b0b7b27496a852753559bbc
    )

    # x86_64-pc-windows-msvc
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/rustc-1.68.2-x86_64-pc-windows-msvc.tar.xz"
        SHA512 7adf5123a0bd37665245e8e831002d85e67325681deef5ee21f305b1c33649db8a57c42d6647ea0ae5d8c5354ed8e9e6667c3579fe4aca73da81ba8c009a9852
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/rust-std-1.68.2-x86_64-pc-windows-msvc.tar.xz"
        SHA512 f1fd90e3675bee2c61c858b68e2481b7e2623d6d88a9d9ab28923541bc5359e83e2b04c1a231b991ddae7b4ec2d9094a32a32f9c04a456b3c9a674fd433bc0b5
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/cargo-1.68.2-x86_64-pc-windows-msvc.tar.xz"
        SHA512 fc745e7c8ab369131d3899ac19c8fde75ab506ee69fe7c9e88d542b7504072ca244508406461f5eceaa95887127a5e37fd0914a535f654691743ae1d1ee26d84
    )

    # i686-unknown-linux-gnu
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/rustc-1.68.2-i686-unknown-linux-gnu.tar.xz"
        SHA512 5a1cebf2751430fe68b5a2d3435dda82a1da00ee6bba1140e44fbcc4a7a496a17b2a3fc585a1c269799b92330a11675fd20f1e879271ace466eb03d4c8909bb3
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/rust-std-1.68.2-i686-unknown-linux-gnu.tar.xz"
        SHA512 306e9597a5f4e4e9cb70d6e9d49ce07c612b1ab1d1994a99dee01abe9c159c2b9ec1ccbf098aa7fa8f9f8535ca9b504b13fff100bdc5b242c25474ea6376d2ed
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/cargo-1.68.2-i686-unknown-linux-gnu.tar.xz"
        SHA512 72f053663bad2428cb11c182396b27c4fc5f4e94c5e68f67d78e02211ab900e4c07f1a0a3d2092ce66eeec250b64e21e8b391036e0be1d1bc44ec57bbf3bb582
    )

    # x86_64-unknown-linux-gnu
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/rustc-1.68.2-x86_64-unknown-linux-gnu.tar.xz"
        SHA512 0e4410eb8436ef475e6193d7ee07fb4bab140a1a0d8ff0370ab34452f62c5d0f39a1b35c3902aef3391b08b5808961506fbd7d5cdd27428ae9584331be450b2c
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/rust-std-1.68.2-x86_64-unknown-linux-gnu.tar.xz"
        SHA512 01dc735cf9d3c54ea27095d79cd5cdcf87d4707c0842dabfe335750ae8209ea509ee2777d623d6dba9f6a4a969df18c8451a3baa99180df08dceb7a2383ae081
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-28/cargo-1.68.2-x86_64-unknown-linux-gnu.tar.xz"
        SHA512 473b59c8bad09d102d1af9dc6e87099bb898b2321f5985442e62f556b6e7fd8b338a95f6003d68743508f9e6353ca6881efe40018600aff4de1fa281b794098b
    )

    if(NOT Z_VCPKG_RUST_PACKAGES STREQUAL "")
        message(FATAL_ERROR "Unknown packages were required for vcpkg_rust_acquire(${arg_PACKAGES}): ${packages}
This can be resolved by explicitly passing URL/SHA pairs to DIRECT_PACKAGES.")
    endif()

    string(SHA512 total_hash "${Z_VCPKG_RUST_TOTAL_HASH}")
    string(SUBSTRING "${total_hash}" 0 16 total_hash)
    set(path_to_root "${DOWNLOADS}/tools/rust/${total_hash}")
    if(NOT EXISTS "${path_to_root}")
        file(REMOVE_RECURSE "${path_to_root}.tmp")
        set(index 0)
        foreach(archive IN LISTS Z_VCPKG_RUST_ARCHIVES)
			file(MAKE_DIRECTORY "${path_to_root}.tmp/staging-${archive}")
            vcpkg_execute_required_process(
                ALLOW_IN_DOWNLOAD_MODE
                COMMAND "${CMAKE_COMMAND}" -E tar xzf "${Z_VCPKG_RUST_${archive}_ARCHIVE}"
                LOGNAME "rust-${TARGET_TRIPLET}-${index}-tar"
                WORKING_DIRECTORY "${path_to_root}.tmp/staging-${archive}"
            )
			
			if(Z_VCPKG_RUST_${archive}_ARCHIVE MATCHES [[^.*/rust-(([a-z_-]+)-[0-9]+\.[0-9]+\.[0-9]-([a-z0-9_]+-[a-z0-9_-]+))\.tar\.xz$]])
				if(${CMAKE_MATCH_2} STREQUAL "rust-std")
					set(directory "${CMAKE_MATCH_1}/${CMAKE_MATCH_2}-${CMAKE_MATCH_3}")
				else()
					set(directory "${CMAKE_MATCH_1}/${CMAKE_MATCH_2}")
				endif()
			
				vcpkg_execute_required_process(
					ALLOW_IN_DOWNLOAD_MODE
					COMMAND "${CMAKE_COMMAND}" -E copy_directory "${path_to_root}.tmp/staging-${archive}/${directory}" "${path_to_root}.tmp/"
					LOGNAME "rust-${TARGET_TRIPLET}-${index}-copy"
					WORKING_DIRECTORY "${path_to_root}.tmp"
				)
				vcpkg_execute_required_process(
					ALLOW_IN_DOWNLOAD_MODE
					COMMAND "${CMAKE_COMMAND}" -E rm -Rf "${path_to_root}.tmp/staging-${archive}"
					LOGNAME "rust-${TARGET_TRIPLET}-${index}-rm"
					WORKING_DIRECTORY "${path_to_root}.tmp"
				)
			else()
				MESSAGE(FATAL_ERROR "internal error: Regex for getting package path from archive name didn't match")
			endif()
			
            math(EXPR index "${index} + 1")
        endforeach()
        file(RENAME "${path_to_root}.tmp" "${path_to_root}")
    endif()
    message(STATUS "Using rust root at ${path_to_root}")
    set("${out_rust_root}" "${path_to_root}" PARENT_SCOPE)
endfunction()

function(vcpkg_rust_install)
	find_program(CARGO cargo HINTS ENV CARGO_HOME PATH_SUFFIXES "bin" PATHS ENV PATH)
	if(CARGO)
		message(STATUS "Using system rust cargo: ${CARGO}")
	else()
		message(STATUS "No system rust cargo found, installing.")
		z_vcpkg_rust_install_packages(path_to_root)
		vcpkg_add_to_path("${path_to_root}/bin")
	endif()
endfunction()
