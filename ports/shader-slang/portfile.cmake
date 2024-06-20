vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(key NOTFOUND)
if(VCPKG_TARGET_IS_WINDOWS)
	set(key "windows-${VCPKG_TARGET_ARCHITECTURE}")
elseif(VCPKG_TARGET_IS_OSX)
	set(key "macosx-${VCPKG_TARGET_ARCHITECTURE}")
elseif(VCPKG_TARGET_IS_LINUX)
	set(key "linux-${VCPKG_TARGET_ARCHITECTURE}")
endif()
string(REPLACE "arm64" "aarch64" key "${key}")

set(ARCHIVE NOTFOUND)
# For convenient updates, use 
# vcpkg install shader-slang --cmake-args=-DVCPKG_SHADER_SLANG_UPDATE=1
if(key STREQUAL "windows-x86" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win32.zip"
		FILENAME "slang-${VERSION}-win32.zip"
		SHA512 b8fa6aed2fc4c7adb8c1810cfa5e655b317aebc4636e8d80e718aef25abf58bc9dc5c7c58dc9d0a375d61bed8000daa75e14d8bc11c1a7c4cd33350d698c8dd6
	)
endif()
if(key STREQUAL "windows-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win64.zip"
		FILENAME "slang-${VERSION}-win64.zip"
		SHA512 24d39f1f54230b7badc1e0e3b54b29a0fddbcf29c2370d2085870556529f8ee4d25d249b9dad9bead61079803061f6a7d7b126e136fcb8afe2a0ef61808f34ad
	)
endif()
if(key STREQUAL "windows-aarch64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win-arm64.zip"
		FILENAME "slang-${VERSION}-win-arm64.zip"
		SHA512 0971394479f4da56b6340c1bc9b415ac1de001607ba5af0d5e3e3e95ad9a4e2fd6185603bb95fdc98e152d0a6012a5af144ba812c3af0ec1d1eb50837caad3dd
	)
endif()
if(key STREQUAL "macosx-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x64.zip"
		FILENAME "slang-${VERSION}-macos-x64.zip"
		SHA512 e546c4c3e68880f75678c061457369f2c075bdd428080c4af7fae6145be8359dff182902d412dad6c0ce3903004ca9613d791a04a209e6e16960e036585efdae
	)
endif()
if(key STREQUAL "macosx-aarch64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
		FILENAME "slang-${VERSION}-macos-aarch64.zip"
		SHA512 df287ec31d366d88196ce5e1a9d3fa0d0c6973ff948c8ab4e51a04d3f5af5b84a8703925a6a5b721335f2cbfcb0fb0e70eac5d084f72565fe65730ae54a758fa
	)
endif()
if(key STREQUAL "linux-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.zip"
		FILENAME "slang-${VERSION}-linux-x86_64.zip"
		SHA512 6a2360936e8c3967ebbf6a1ea8143c6e2ddf188c3057f3ecafac28550f96ba83f7269a9ef5dadc76833c78954dca298b901f63f94cbf595fb68d1138fa361f62
	)
endif()
if(key STREQUAL "linux-aarch64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64.zip"
		FILENAME "slang-${VERSION}-linux-aarch64.zip"
		SHA512 315a822d32093bbe133f399eb648301a3b0f3319aabe526371b8044b691e16aa826d9c81af59f1967e9d98e94d55fb5e4704cafb831fb518442755a4574d5498
	)
endif()
if(NOT ARCHIVE)
	message(FATAL_ERROR "Unsupported platform. Please implement me!")
endif()

vcpkg_extract_source_archive(
	BINDIST_PATH
	ARCHIVE "${ARCHIVE}"
	NO_REMOVE_ONE_LEVEL
)

# https://github.com/shader-slang/slang/issues/4117
if(NOT EXISTS "${BINDIST_PATH}/LICENSE" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		LICENSE_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-source.zip"
		FILENAME "slang-${VERSION}-source.zip"
		SHA512 4c0888de421e070e8458b94e420df972c5b4fb5f3d3dc3c124b8f33f548aa47cd81d7c92c33786b492373b926263167f9ef63f8fe203e064f1f0795b38cf1570
	)
	vcpkg_extract_source_archive(
		SOURCE_PATH
		ARCHIVE "${LICENSE_ARCHIVE}"
		NO_REMOVE_ONE_LEVEL
	)
	file(COPY "${SOURCE_PATH}/LICENSE" DESTINATION "${BINDIST_PATH}")
endif()

if(VCPKG_SHADER_SLANG_UPDATE)
	message(STATUS "All downloads are up-to-date.")
	message(FATAL_ERROR "Stopping due to VCPKG_SHADER_SLANG_UPDATE being enabled.")
endif()

set(SLANG_BIN_PATH "bin/${key}/release")
file(GLOB libs
	"${BINDIST_PATH}/${SLANG_BIN_PATH}/*.lib"
	"${BINDIST_PATH}/${SLANG_BIN_PATH}/*.dylib"
	"${BINDIST_PATH}/${SLANG_BIN_PATH}/*.so"
)
file(INSTALL ${libs} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

if(VCPKG_TARGET_IS_WINDOWS)
	file(GLOB dlls "${BINDIST_PATH}/${SLANG_BIN_PATH}/*.dll")
	file(INSTALL ${dlls} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

if(NOT VCPKG_BUILD_TYPE)
	file(INSTALL "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
	if(VCPKG_TARGET_IS_WINDOWS)
		file(INSTALL "${CURRENT_PACKAGES_DIR}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
	endif()
endif()

vcpkg_copy_tools(TOOL_NAMES slangc slangd SEARCH_DIR "${BINDIST_PATH}/${SLANG_BIN_PATH}")

file(GLOB headers "${BINDIST_PATH}/*.h" "${BINDIST_PATH}/prelude")
file(INSTALL ${headers} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
	FILE_LIST "${BINDIST_PATH}/LICENSE"
	COMMENT #[[ from README ]] [[
The Slang code itself is under the MIT license.

Builds of the core Slang tools depend on the following projects, either automatically or optionally, which may have their own licenses:

* [`glslang`](https://github.com/KhronosGroup/glslang) (BSD)
* [`lz4`](https://github.com/lz4/lz4) (BSD)
* [`miniz`](https://github.com/richgel999/miniz) (MIT)
* [`spirv-headers`](https://github.com/KhronosGroup/SPIRV-Headers) (Modified MIT)
* [`spirv-tools`](https://github.com/KhronosGroup/SPIRV-Tools) (Apache 2.0)
* [`ankerl::unordered_dense::{map, set}`](https://github.com/martinus/unordered_dense) (MIT)

Slang releases may include [slang-llvm](https://github.com/shader-slang/slang-llvm) which includes [LLVM](https://github.com/llvm/llvm-project) under the license:

* [`llvm`](https://llvm.org/docs/DeveloperPolicy.html#new-llvm-project-license-framework) (Apache 2.0 License with LLVM exceptions)
]])
