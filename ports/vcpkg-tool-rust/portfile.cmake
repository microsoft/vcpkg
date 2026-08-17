set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_FIXUP_MACHO_RPATH OFF)
set(VCPKG_FIXUP_ELF_RPATH OFF)

set(rust_program_name rustc)
set(cargo_program_name cargo)
set(program_version 1.97.1)

if (VCPKG_TARGET_IS_WINDOWS)
  if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(download_filename_suffix "aarch64-pc-windows-msvc")
    set(download_sha512 "82717b8e34ad78391b4b611a6e4a4912440f30157d6eec30002726af0c8804dbe42ab596234d7e10db271cc26c0dba678d611eafd04d6d71dd83d203ad64bee9")
  elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(download_filename_suffix "i686-pc-windows-msvc")
    set(download_sha512 "1b7e5ad281aaea187a84b025b981dcbe0a9da1fd134b4d926af5896e5a876b15c8aab19d4bdbab56fc92af5250946db36e3049fa0e95320d0cfdfa8005c4c5a8")
  else()
    set(download_filename_suffix "x86_64-pc-windows-msvc")
    set(download_sha512 "0200f0c3a1bbf2ce2455e9c25324478d3bd1d4033eea33cb3cf62f4c34f6c63930dfc843bcd080f44621904224db549d2256553e0c2ff296fff54d8d42555e4c")
  endif()
elseif(VCPKG_TARGET_IS_OSX)
  if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(download_filename_suffix "aarch64-apple-darwin")
    set(download_sha512 "5a4b84c7e69c32e52b7eabf8e8c7f14c8e20990f42d61b8d409eb9f3749e61f96fef9bf572130db7dc25baa64d9cd66d0cf0920c818f8e846326779c7f8d0cdb")
  else()
    set(download_filename_suffix "x86_64-apple-darwin")
    set(download_sha512 "dcda23b347b71342ac456ceb29d7b2918a1fd94dc038f4c09fab3ec3dac6e9489c62ce41d81bca8f8f8877240d1f58c06b47dba9d81de3cb1e4ebd29bba4f8c2")
  endif()
else()
  if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(download_filename_suffix "aarch64-unknown-linux-gnu")
    set(download_sha512 "9d57618597060387ffd93c46c49614e70f14b72f2c1df18d5da4334e50d83a81fb452261c39edb20b541a12b7f11ffb9451bc778bd115f5e80b8c6c9cc009de5")
  else()
    set(download_filename_suffix "x86_64-unknown-linux-gnu")
    set(download_sha512 "1f584669264f1fc5ae61a6d642395c94fc16d35fcf720863531fe98bc29cb83217785de4f7e0be97f0fe67e52700a75f799eb9e7fb36cbeeb4096091da087c4c")
  endif()
endif()
set(download_filename "rust-${program_version}-${download_filename_suffix}")
set(download_urls "https://static.rust-lang.org/dist/${download_filename}.tar.xz")
set(paths_to_search "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_download_distfile(archive_path
    URLS ${download_urls}
    SHA512 "${download_sha512}"
    FILENAME "${download_filename}"
)
set(output_path "${CURRENT_PACKAGES_DIR}/tools")
file(MAKE_DIRECTORY "${output_path}")

message(STATUS "Extracting RUST tool ...")
vcpkg_extract_archive(
    ARCHIVE "${archive_path}"
    DESTINATION "${CURRENT_BUILDTREES_DIR}/tmp_rust"
)
message(STATUS "Extracting RUST tool ... finished!")

if (EXISTS "${CURRENT_BUILDTREES_DIR}/tmp_rust/${download_filename}")
  file(RENAME "${CURRENT_BUILDTREES_DIR}/tmp_rust/${download_filename}" "${paths_to_search}")
  file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/tmp_rust")
else()
  message(FATAL_ERROR "Cannot find the extracted RUST in '${CURRENT_BUILDTREES_DIR}/tmp_rust/${download_filename}'")
endif()

file(COPY "${paths_to_search}/rust-std-${download_filename_suffix}/lib/" 
     DESTINATION "${paths_to_search}/rustc/lib"
)
file(COPY "${paths_to_search}/rustc/lib/rustlib/${download_filename_suffix}/bin/" 
     DESTINATION "${paths_to_search}/rustc/bin"
)

# Clean up other folders that are not important
file(GLOB PREVIEW_FOLDERS LIST_DIRECTORIES true
        "${paths_to_search}/*-preview"
        "${paths_to_search}/*-${download_filename_suffix}")
if(PREVIEW_FOLDERS)
  file(REMOVE_RECURSE ${PREVIEW_FOLDERS})
endif()

file(GLOB TARGET_FILES 
    "${paths_to_search}/builder-config"
    "${paths_to_search}/components"
    "${paths_to_search}/git-*"
    "${paths_to_search}/install.sh"
    "${paths_to_search}/rust-installer-version"
)
if(TARGET_FILES)
    file(REMOVE ${TARGET_FILES})
endif()

# Find the RUST and Cargo applications
message(STATUS "paths_to_search: ${paths_to_search}")
z_vcpkg_find_acquire_program_find_internal("RUST"
    PATHS "${paths_to_search}" "${paths_to_search}/rustc/bin"
    NAMES ${rust_program_name}
)
z_vcpkg_find_acquire_program_find_internal("CARGO"
    PATHS "${paths_to_search}" "${paths_to_search}/cargo/bin"
    NAMES ${cargo_program_name}
)
if(NOT RUST)
  message(FATAL_ERROR "Unable to find RUST: ${RUST}")
endif()
if(NOT CARGO)
  message(FATAL_ERROR "Unable to find CARGO: ${CARGO}")
endif()

message(STATUS "Using RUST: ${RUST}")
message(STATUS "Using CARGO: ${CARGO}")

# Fix the internal macOS runtime path (rpath)
if(VCPKG_TARGET_IS_OSX)
  message(STATUS "Fixing rustc rpath for macOS compatibility...")

  vcpkg_execute_required_process(
    COMMAND install_name_tool -add_rpath "@executable_path/../lib" "${RUST}"
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
    LOGNAME "fix-rustc-rpath"
  )
elseif(VCPKG_TARGET_IS_LINUX)
  message(STATUS "Fixing Linux RUNPATH for rustc...")

  find_program(PATCHELF_EXE patchelf REQUIRED)

  vcpkg_execute_required_process(
    COMMAND "${PATCHELF_EXE}" --set-rpath "$$ORIGIN/../lib" "${RUST}"
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
    LOGNAME "fix-rustc-rpath"
  )
endif()

set(details "set(program_version \"${program_version}\")\n")
string(APPEND details "set(paths_to_search \"\${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}\")\n")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/details.cmake" "${details}")
