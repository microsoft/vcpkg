set(orig_VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE})

set(CEF_VERSION "81.3.8")
set(CHROMIUM_VERSION "81.0.4044.138")
set(PLATFORM_NAME "windows64")
set(COMMIT_SHORTHASH "g1a0137c")
set(ARCHIVE_HASH "7626bcf8bb7ec98575dd91ea6a726eb35567c6939b6387bd5c8c400bc4918dc4a4575d9879ad40cc51c1627c0fcfaf2448d2d4259e2a3748ba7aa183cb1400cc")

set(FOLDER_NAME "cef_binary_${CEF_VERSION}+${COMMIT_SHORTHASH}+chromium-${CHROMIUM_VERSION}_${PLATFORM_NAME}")
set(ARCHIVE_NAME "${FOLDER_NAME}.tar.bz2")

# Download
vcpkg_download_distfile(
	ARCHIVE
	URLS "https://cef-builds.spotifycdn.com/${ARCHIVE_NAME}"
	FILENAME "${ARCHIVE_NAME}"
	SHA512 ${ARCHIVE_HASH}
)

# Extract
vcpkg_extract_source_archive_ex(
	OUT_SOURCE_PATH SOURCE_PATH
	ARCHIVE "${ARCHIVE}"
	REF "${CEF_VERSION}"
	# NO_REMOVE_ONE_LEVEL
)

message("Extract archive: ${ARCHIVE}")
message("To path: ${SOURCE_PATH}")

# Required, or else libcef.lib gives the error "Could not find proper second linker member." Chromium does the same: https://github.com/microsoft/vcpkg/blob/030cfaa24de9ea1bbf0a4d9c615ce7312ba77af1/ports/chromium-base/portfile.cmake
set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)

# Temporarily override linker config to build properly
set(VCPKG_LIBRARY_LINKAGE static)

# Disable PREFER_NINJA because it changes the output directories slightly
vcpkg_configure_cmake(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
		-DCEF_RUNTIME_LIBRARY_FLAG=/MD
)

# Restore linker config
set(VCPKG_LIBRARY_LINKAGE ${orig_VCPKG_LIBRARY_LINKAGE})

vcpkg_build_cmake(
	TARGET libcef_dll_wrapper
)

message("CURRENT_PACKAGES_DIR: ${CURRENT_PACKAGES_DIR}")

set(RELEASE_BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${HOST_TRIPLET}-rel")
set(DEBUG_BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${HOST_TRIPLET}-dbg")

#########################################

# /lib release
file(
	COPY
		"${RELEASE_BUILD_DIR}/libcef_dll_wrapper/Release/libcef_dll_wrapper.lib"
		"${RELEASE_BUILD_DIR}/libcef_dll_wrapper/Release/libcef_dll_wrapper.pdb"
		"${SOURCE_PATH}/Release/libcef.lib"
	DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
)

# /bin release
file(
	COPY "${SOURCE_PATH}/Release/libcef.dll"
	DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
)

# /lib debug
file(
	COPY
		"${DEBUG_BUILD_DIR}/libcef_dll_wrapper/Debug/libcef_dll_wrapper.lib"
		"${DEBUG_BUILD_DIR}/libcef_dll_wrapper/Debug/libcef_dll_wrapper.pdb"
		"${SOURCE_PATH}/Debug/libcef.lib"
	DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
)

# /bin debug
file(
	COPY "${SOURCE_PATH}/Debug/libcef.dll"
	DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
)

# /include
file(
	COPY "${SOURCE_PATH}/include"
	DESTINATION "${CURRENT_PACKAGES_DIR}"
)

# Another /include for cef's own imports
file(
	COPY "${SOURCE_PATH}/include"
	DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

# /copyright
file(
	INSTALL "${SOURCE_PATH}/LICENSE.txt"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright)
