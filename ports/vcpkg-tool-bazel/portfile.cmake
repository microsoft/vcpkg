set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(key NOTFOUND)
if(VCPKG_CMAKE_SYSTEM_NAME)
    set(key "${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}")
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(key "Windows-${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(archive_path NOTFOUND)
# For convenient updates, use 
# vcpkg install vcpkg-tool-bazel --cmake-args=-DVCPKG_BAZEL_UPDATE=1
if(key STREQUAL "Linux-arm64" OR VCPKG_BAZEL_UPDATE)
    set(filename "bazel-${VERSION}-linux-arm64")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/${filename}"
		FILENAME "${filename}"
		SHA512 c3277c84db26c3fb18852aa450bd27f2b2a2e1dce0d3d5257469f6986387609c242b2e15bfc1534a4a5616b877924e54a994c2d3ecb9e26cf7a60816c7dbe50b
	)
endif()
if(key STREQUAL "Linux-x64" OR VCPKG_BAZEL_UPDATE)
    set(filename "bazel-${VERSION}-linux-x86_64")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/${filename}"
		FILENAME "${filename}"
		SHA512 6c4a7d4baebef47a81f5c6377fa8919f66c96f22f73f945e37b82d61f1a94ec52a3d222dea401cfc7eff6bba8a43923d4cce1f74f2124a6362a0afac892137ad
	)
endif()
if(key STREQUAL "Darwin-arm64" OR VCPKG_BAZEL_UPDATE)
    set(filename "bazel-${VERSION}-darwin-arm64")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/${filename}"
		FILENAME "${filename}"
		SHA512 269ad12b8fcb2e561366d8980b5ca297d254a074cbd121691415e3cf9a221706772aac26cb823fe114232ca43e4387fb9f3a1e38d3b61254848d636a2850b3b4
	)
endif()
if(key STREQUAL "Darwin-x64" OR VCPKG_BAZEL_UPDATE)
    set(filename "bazel-${VERSION}-darwin-x86_64")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/${filename}"
		FILENAME "${filename}"
		SHA512 6b50164eb6f72a08f6a54bea960dec2dd7da3c7acc076643a989816f80507eee4271f673a8ef749b5168b31b0cb271dbc374daf2afe8b4acf7ad176ae778e571
	)
endif()
if(key STREQUAL "Windows-arm64" OR VCPKG_BAZEL_UPDATE)
    set(filename "bazel-${VERSION}-windows-arm64.exe")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/${filename}"
		FILENAME "${filename}"
		SHA512 5fe6cb55df6d47e40590ee08a2ea11e3a11e8e9001a6a9cb1da7e8960b38242b9733df4b29fba58882b97da76773a1fa696e1f50f19810bd1867e1ed5afe4abb
	)
endif()
if(key STREQUAL "Windows-x64" OR VCPKG_BAZEL_UPDATE)
    set(filename "bazel-${VERSION}-windows-x86_64.exe")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/${filename}"
		FILENAME "${filename}"
		SHA512 a6a028c7965ed391b786e1ccb67c4c4bfeee063dfa60b0ed3c8dee3317ce1e2e18914fcf053ba5c00e95d03ac15a55c719285448626a560fa1dd95baa351f145
	)
endif()
if(NOT archive_path)
	message(FATAL_ERROR "Unsupported platform. Please implement me!")
endif()

if(VCPKG_BAZEL_UPDATE)
	message(STATUS "All downloads are up-to-date.")
	message(FATAL_ERROR "Stopping due to VCPKG_BAZEL_UPDATE being enabled.")
endif()

message(STATUS "archive_path: '${archive_path}'")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(INSTALL "${archive_path}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools"
    RENAME "bazel"
    FILE_PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
)

# Avoid breaking the code signature.
set(VCPKG_FIXUP_MACHO_RPATH OFF)
