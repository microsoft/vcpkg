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
			SHA512 3d6153d9cd8234d68d91273b97cfd66167e55bf3c526490603c79797aea4f5af839cbfdce29532da8c0e77cb9e6451a5823d40b98162fb53fffcbc5d18b0f841
		)
		set(SLANG_BIN_PATH "bin/windows-x64/release")
	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win32.zip"
			FILENAME "slang-${VERSION}-win32.zip"
			SHA512 43992831be8f7fc954794482e947a20e421587cb999eebdd7ffb21c3fc477a660ae19c0e0a10df5331329ac46e7fdd6017fc416b6667127182ae6091b6431e6b
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
			SHA512 dc3b3f18c8e80cfc12960e76978dc1acb18df6de0704c5a889713128491827e26c169a2965d598b4904647384da2eeceb63a391b62925573da5d77a060bdb890
		)
		set(SLANG_BIN_PATH "bin/macos-x64/release")
	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
			FILENAME "slang-${VERSION}-macos-aarch64.zip"
			SHA512 db613040ea31fa2ff8a60fec96a16704e0241774332333a704530bee309f5037d50570fc590348f22d3bc7f018a5bd3c9a10aae800a4f30f0f5e273552690863
		)
		set(SLANG_BIN_PATH "bin/macos-aarch64/release")
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
			SHA512 817e3c5ae9fa249c54b1f411877f4742a019aa27b63bfb06b726b721cd86973b4ebe481bf62192bb7380d092c57cbd8e2abc932a7dbacd06811b6afb856c428d
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
	SHA512 f7da1cd60418c9b0a4f302841154ac5b48f84b897f81359cbc52950dd5a2a0339a95b8cc13ad13d518a089aff3071bf52f60bcf86d29b07866c4e1c948f5ccfd
	HEAD_REF master
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
