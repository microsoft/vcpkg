set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(key NOTFOUND)
if(VCPKG_CMAKE_SYSTEM_NAME)
    set(key "${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}")
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(key "Windows-${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_download_distfile(license
	URLS "https://github.com/tree-sitter/tree-sitter/raw/refs/tags/v${VERSION}/LICENSE"
	FILENAME "tree-sitter-v${VERSION}-LICENSE"
	SHA512 568a9113476b2f4a542303ae3b329686e2fffd0b29b96a0acc50181ff248ac144f63017d5e376d9b870e33f3bd6063a2aba1d1c0a6c7708dd589ffb67a17491a
)

set(archive_path NOTFOUND)
# For convenient updates, use
# vcpkg install tree-sitter-cli --cmake-args=-DVCPKG_TREE_SITTER_UPDATE=1
if(key STREQUAL "Linux-arm64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-linux-arm64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-linux-arm64.gz"
        FILENAME "${filename}"
        SHA512 aeb55a6ed3e69c11c24cfa9406af2600a519ec5753fc91d173a617ec0c3d19734fdfcd5f45e581abf82da13937e37871d7a8ba2e5d114448df3235e7624e2154
    )
endif()
if(key STREQUAL "Linux-x64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-linux-x64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-linux-x64.gz"
        FILENAME "${filename}"
        SHA512 4d6a52eb1bab7b30d1c366ccfcd51b8bb8dd2e58efd0adca0d7cdaecbaaedac2442b0f8e0a6e05b943349443818ee3e2b18870ab2fda7f4c1839b869161b938c
    )
endif()
if(key STREQUAL "Darwin-arm64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-macos-arm64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-macos-arm64.gz"
        FILENAME "${filename}"
        SHA512 300e20ef74dcaf6ce41bc31086d0a436448ac397e72c048f885ba5f827f7c664eab45682dbc80c05d08f66a1ca91f10f287054660943ae9a891b464d6b586cd3
    )
    # Avoid breaking the code signature.
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()
if(key STREQUAL "Darwin-x64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-macos-x64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-macos-x64.gz"
        FILENAME "${filename}"
        SHA512 e01bec89a91ed704d9f333b767766899f73347572cf3249f57b5172f20026e2b46196ae02f5a3809e1378ded066c3893a43c18b642d0d775a20f80641f623beb
    )
    # Avoid breaking the code signature.
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()
if(key STREQUAL "Windows-arm64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-windows-arm64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-windows-arm64.gz"
        FILENAME "${filename}"
        SHA512 a1cbb94a5fcb7cf1bbb1cbc3427874829269325cc36931f1ddf100d524aade6f75b229709e28ddef47290a50ec9d4a66ff42a5c28803033b8c5c8d48ccc6fe60
    )
endif()
if(key STREQUAL "Windows-x64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-windows-x64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-windows-x64.gz"
        FILENAME "${filename}"
        SHA512 612bf850788ee635c09aa78e400168e5d7f5a8952c954e4116722127426a1b0e2bd0cdb2c4e04d803ffd03e743c9236b708f6b0779743f549267e6eca66c0bfb
    )
endif()
if(NOT archive_path)
    message(FATAL_ERROR "Unsupported platform '${key}'. Please implement me!")
endif()

if(VCPKG_TREE_SITTER_UPDATE)
    message(STATUS "All downloads are up-to-date.")
    message(FATAL_ERROR "Stopping due to VCPKG_TREE_SITTER_UPDATE being enabled.")
endif()

file(COPY "${archive_path}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
cmake_path(GET archive_path FILENAME archive_name)
set(gunzip_command_line gunzip "${archive_name}")
if(CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_ROOT)
    vcpkg_host_path_list(APPEND ENV{PATH} "${MSYS_ROOT}/usr/bin")
	set(gunzip_command_line sh -c "gunzip '${archive_name}'")
endif()
vcpkg_execute_required_process(
    ALLOW_IN_DOWNLOAD_MODE
    COMMAND ${gunzip_command_line}
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    LOGNAME "gunzip-${TARGET_TRIPLET}"
)
string(REGEX REPLACE "[.]gz\$" "" tool_name "${archive_name}")
file(RENAME "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${tool_name}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/tree-sitter${VCPKG_HOST_EXECUTABLE_SUFFIX}")
file(CHMOD "${CURRENT_PACKAGES_DIR}/tools/${PORT}/tree-sitter${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)

vcpkg_install_copyright(FILE_LIST "${license}"
	COMMENT [[
Tree-sitter is licensed under the MIT license. The tree-sitter CLI uses
third-party components which are not listed individually here.
]])
