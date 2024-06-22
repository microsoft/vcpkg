vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if (VCPKG_TARGET_IS_WINDOWS)
	set(SLANG_EXE_SUFFIX ".exe")
	set(SLANG_LIB_PREFIX "")
	set(SLANG_LIB_SUFFIX ".lib")
	set(SLANG_DYNLIB_SUFFIX ".dll")
	if (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win64.zip"
			FILENAME "slang-${VERSION}-win64.zip"
			SHA512 2ccd30db91afbc927446e200ed1daaeb4feba2182782f1f45378ff1e339f9360fe74e9144ee7bb7d9811290ce273e1791860a751bf84bd78a244d5cdd6dbc095
		)
		set(SLANG_BIN_PATH "bin/windows-x64/release")
	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win32.zip"
			FILENAME "slang-${VERSION}-win32.zip"
			SHA512 072e918d1047845be24ae16e09fc8d1afdaacdc49a015574b585970288cc3a80b113518aea5e70bd392fc225d021cae0b22cc96d2028ef9b523196491da3ee3a
		)
		set(SLANG_BIN_PATH "bin/windows-x86/release")
	else()
		message(FATAL_ERROR "Unsupported platform. Please implement me!")
	endif()
elseif (VCPKG_TARGET_IS_OSX)
	set(SLANG_EXE_SUFFIX "")
	set(SLANG_LIB_PREFIX "lib")
	set(SLANG_LIB_SUFFIX ".a")
	set(SLANG_DYNLIB_SUFFIX ".dylib")
	if (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x64.zip"
			FILENAME "slang-${VERSION}-macos-x64.zip"
			SHA512 3c5524d0cb0ef606f421d5399564083f84f8a2040a7f29d48dfded91a8b5c817cf7ec4de7e52dd2b837059877be477c7b2b46d4204af9190128e072413e8fd88
		)
		set(SLANG_BIN_PATH "bin/macosx-x64/release")
	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
			FILENAME "slang-${VERSION}-macos-aarch64.zip"
			SHA512 adabbe36efa1dcefe0803f867c1f3f32cccd2bf138055035274f019060b02af2a738084ae756e877f63c43404537e934c52717234cb2d82150b4327cf382f05c
		)
		set(SLANG_BIN_PATH "bin/macosx-aarch64/release")
	else()
		message(FATAL_ERROR "Unsupported platform. Please implement me!")
	endif()
elseif(VCPKG_TARGET_IS_LINUX)
	set(SLANG_EXE_SUFFIX "")
	set(SLANG_LIB_PREFIX "lib")
	set(SLANG_LIB_SUFFIX ".a")
	set(SLANG_DYNLIB_SUFFIX ".so")
	if (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.tar.gz"
			FILENAME "slang-${VERSION}-linux-x86_64.tar.gz"
			SHA512 e4c270207e8eccd918d28279acb3fe3f5a065a1b2530cca79f3cf14d482f2a68f6e357ba1d3360b0fc2b4d87fc43e06962cb768652a0d2ccea740b18402fc6ed
		)
		set(SLANG_BIN_PATH "bin/linux-x64/release")
	else()
		message(FATAL_ERROR "Unsupported platform. Please implement me!")
	endif()
else()
	message(FATAL_ERROR "Unsupported platform. Please implement me!")
endif()

vcpkg_extract_source_archive(
	BINDIST_PATH
	ARCHIVE "${ARCHIVE}"
	NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_WINDOWS)
  file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-llvm${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
  file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-llvm${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-glslang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-glslang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

# Must install dynamic libraries for slangc compiler
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_WINDOWS)
  file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-llvm${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-glslang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/slangc${SLANG_EXE_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
  execute_process(COMMAND sh -c "chmod +x slangc" WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

if (VCPKG_TARGET_IS_WINDOWS)
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/gfx${SLANG_LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/gfx${SLANG_LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/gfx${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/gfx${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB HEADERS "${BINDIST_PATH}/*.h")
file(INSTALL ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO shader-slang/slang
	REF "v${VERSION}"
	SHA512 dbba9a27ed3adf05167dcb007191601083389d462721b88de07f66ee13eb5027174cb1e8506fd334bfb739295364b6a1340393fa98baec72abcea1ded13fdf73
	HEAD_REF master
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
