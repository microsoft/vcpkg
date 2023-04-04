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
        if(${CMAKE_MATCH_4} STREQUAL "x86_64")
            set(arg_ARCH "x64")
		elseif(${CMAKE_MATCH_4} STREQUAL "i686")
			set(arg_ARCH "x86")
        else()
            message(FATAL_ERROR "internal error: Can't match architecture ${CMAKE_MATCH_4} to vcpkg architecture")    
        endif()
    endif()

    if(NOT DEFINED arg_PLATFORM)
        if(${CMAKE_MATCH_5} STREQUAL "pc-windows-msvc")
            set(arg_PLATFORM "windows")
        else()
            message(FATAL_ERROR "internal error: Can't match platform ${CMAKE_MATCH_5} to vcpkg platform")
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

    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-09/rustc-1.68.0-x86_64-pc-windows-msvc.tar.xz"
        SHA512 a8774dcd06b942251c112394d5fac9e4149b0c4933f9f7c922595863b19f4435b3334487927e68bfe9dedb55e4257a2b4c7c9992e6effb935cc053885b90ca5a
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-09/rustc-1.68.0-i686-pc-windows-msvc.tar.xz"
        SHA512 cbd5d0874385b6aa79421911ee6b1f5db0c41dd8bcc8ca2aa0501dc1aee8a51b1f79dd0ed012f563de5d6c908172d850ab822410de8c7ca7c82ba6e55da93da9
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-09/cargo-1.68.0-x86_64-pc-windows-msvc.tar.xz"
        SHA512 8f9164541cdfb05a71d61cf46b4034d80ab236b4f644eafe69706571f299f8f13709abbe58b5d8b6827f95a9d72ac16a52fbe23041c4003b839c492306fc9ce4
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-09/cargo-1.68.0-i686-pc-windows-gnu.tar.xz"
        SHA512 5c90d69211cd752b0d5377f5f56b9308a355da7ee7149f97d87422c1c8e1ce0f66b07281951d302bb347aa540e416778568cbe54326e3f1927bee07f0eaa0829
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-09/rust-std-1.68.0-x86_64-pc-windows-msvc.tar.xz"
        SHA512 a39c1de3b81198cd511e901eae9b835a73740d757d6eb6a36a8d8039f66f74b81b065268fc0eafe9dca5c1c10947728ec00f19e509941774f889b4cdd008859f
    )
    z_vcpkg_rust_acquire_declare_package(
        URL "https://static.rust-lang.org/dist/2023-03-09/rust-std-1.68.0-i686-pc-windows-gnu.tar.xz"
        SHA512 6d27f04f76aea0dbaab2ad9fcb23cd32782178da0dffcca9c3786637b917d28948fea055da9fd2973280e4eb0297445115c62db8b9dd71c31a2400ac452233bb
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
