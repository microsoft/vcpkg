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
			SHA512 24d39f1f54230b7badc1e0e3b54b29a0fddbcf29c2370d2085870556529f8ee4d25d249b9dad9bead61079803061f6a7d7b126e136fcb8afe2a0ef61808f34ad
		)
		set(SLANG_BIN_PATH "bin/windows-x64/release")
	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win32.zip"
			FILENAME "slang-${VERSION}-win32.zip"
			SHA512 b8fa6aed2fc4c7adb8c1810cfa5e655b317aebc4636e8d80e718aef25abf58bc9dc5c7c58dc9d0a375d61bed8000daa75e14d8bc11c1a7c4cd33350d698c8dd6
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
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macosx-x64.zip"
			FILENAME "slang-${VERSION}-macosx-x64.zip"
			SHA512 e546c4c3e68880f75678c061457369f2c075bdd428080c4af7fae6145be8359dff182902d412dad6c0ce3903004ca9613d791a04a209e6e16960e036585efdae
		)
		set(SLANG_BIN_PATH "bin/macosx-x64/release")
	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macosx-aarch64.zip"
			FILENAME "slang-${VERSION}-macosx-aarch64.zip"
			SHA512 df287ec31d366d88196ce5e1a9d3fa0d0c6973ff948c8ab4e51a04d3f5af5b84a8703925a6a5b721335f2cbfcb0fb0e70eac5d084f72565fe65730ae54a758fa
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
			SHA512 5a7842bc4f41ebef1cd0db8ec74440ab38ba061862acced6812b23a9378f1dc9f4922624c3a946f5f655fc8c62172ea84d407bb0036620bbd5e5e4c7fdaffc45
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
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-llvm${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-llvm${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-glslang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-glslang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

# Must install dynamic libraries for slangc compiler
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-llvm${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-glslang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/slangc${SLANG_EXE_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

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
