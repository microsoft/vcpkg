set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(ispc_ver "${VERSION}")
set(file_suffix ".tar.gz")
if(VCPKG_TARGET_IS_WINDOWS)
    set(archive_suffix "-windows")
    set(file_suffix ".msi")
    set(download_sha512 114601db7b787555b1273cad319046d5bb00d5d48f6d449642ad89f04680a780185e599728a0e34706da7c6d32a8a588707427c55e03e9b32850591df8e5d7a4)
elseif(VCPKG_TARGET_IS_OSX)
    set(archive_suffix "-macOS")
    set(download_sha512 44abfd63b4e05bd80f67adfa9051a61815abe58aaa96277d8a54fe9e05788d54a4a6c4b02ee129245fe66a52a35e4a904a629cda5a6d9474e663ba3262b96d6c)
elseif(VCPKG_TARGET_IS_LINUX)
    set(archive_suffix "-linux")
    set(ispc_ver "1.18.1")
    set(download_sha512 704fdda0a3a944da043d9f26b5e71c1a9175bfa915654debf2426ba5482f69a3cc39d11a62515c2c958551d1da6c8d7d6b23bf4608ba7e337e8b57a9e5c81ce7)
endif()

set(subfolder_name "ispc-v${ispc_ver}${archive_suffix}")
set(download_filename "${subfolder_name}${file_suffix}")
set(download_urls "https://github.com/ispc/ispc/releases/download/v${ispc_ver}/${download_filename}")

vcpkg_download_distfile(archive_path
    URLS ${download_urls}
    SHA512 "${download_sha512}"
    FILENAME "${download_filename}"
)

set(output_path "${CURRENT_PACKAGES_DIR}/manual-tools")
file(MAKE_DIRECTORY "${output_path}")
if(VCPKG_TARGET_IS_WINDOWS)

    cmake_path(NATIVE_PATH archive_path archive_path_native) # lessmsi is a bit picky about path formats.
    message(STATUS "Extracting ispc ...")
    vcpkg_execute_in_download_mode(
                    COMMAND "${CURRENT_HOST_INSTALLED_DIR}/tools/vcpkg-tool-lessmsi/lessmsi.exe" x "${archive_path_native}" # Using output_path here does not work in bash
                    WORKING_DIRECTORY "${output_path}"
                    OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/lessmsi-${TARGET_TRIPLET}-out.log"
                    ERROR_FILE "${CURRENT_BUILDTREES_DIR}/lessmsi-${TARGET_TRIPLET}-err.log"
                    RESULT_VARIABLE error_code
                )
    if(error_code)
        message(FATAL_ERROR "Couldn't extract ispc with lessmsi!")
    endif()
    message(STATUS "Extracting ispc ... finished!")
    file(RENAME "${output_path}/${subfolder_name}/SourceDir/ISPC/${subfolder_name}" "${output_path}/ispc/")
    file(REMOVE "${output_path}/${subfolder_name}")
else()
    vcpkg_extract_source_archive(src_path 
                                 ARCHIVE "${archive_path}"
                                  )
    file(RENAME "${src_path}/" "${output_path}/ispc/")
endif()


