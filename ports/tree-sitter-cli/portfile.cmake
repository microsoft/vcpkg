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
        SHA512 da03ba55087a13233e014b8034697dad1d0106f676e6e60fc805477cd10e9671af56e3845d49ad692f9f2d0ea33e242c09e526c247ceb5094bb105834381ae35
    )
endif()
if(key STREQUAL "Linux-x64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-linux-x64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-linux-x64.gz"
        FILENAME "${filename}"
        SHA512 86caf799166ad945b8ed4ddf2b48b9d9acb5ae3e5536244f069467f2996da584a7fe23d45edb37ad7e63a7db8be02525971357fa0a7e7868e3136da68567c578
    )
endif()
if(key STREQUAL "Darwin-arm64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-macos-arm64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-macos-arm64.gz"
        FILENAME "${filename}"
        SHA512 3b088390950f48745ea9afc4caea394abaf0ee445530252e6e5a9784a3ea85d7339a664f38cb337e4e6bbb2d3f05189cfa79316c616ee2c25c724e3a068ef4eb
    )
    # Avoid breaking the code signature.
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()
if(key STREQUAL "Darwin-x64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-macos-x64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-macos-x64.gz"
        FILENAME "${filename}"
        SHA512 b641e8bf21ee66c40f7d9a748fbed3239ac2617be24b0deaf1fdb24e1c9baa5f54bcc9311d4c6a7425cd87032ec9b635deefc62058cbd456839e4e6a52df621a
    )
    # Avoid breaking the code signature.
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()
if(key STREQUAL "Windows-arm64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-windows-arm64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-windows-arm64.gz"
        FILENAME "${filename}"
        SHA512 1d5e78ada1a4fd6f313b1115a97ac3b0e380de190ddbfb4879045cdfc95eefdff9f676aeb53d59ae788f86bf58360cc27c90698e5243ceb25c6b1febec596f1f
    )
endif()
if(key STREQUAL "Windows-x64" OR VCPKG_TREE_SITTER_UPDATE)
    set(filename "tree-sitter-${VERSION}-windows-x64.gz")
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-windows-x64.gz"
        FILENAME "${filename}"
        SHA512 d59a933adc82818570444e09394d28261a416887d12c5fc11839807f01fcd3719ef982344bb4827ffd5c1b72462ed625520803aff86fd24f4f566873fbd9dcd8
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
