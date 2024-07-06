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
		SHA512 e5c2b1062822577fa0fbf0e9d1d9b020bf5b3e079247546b14d460f2ef5cf453e32b5da80d1b5c94b648761d5e5cdd64bcc15e259b52a1e55c2e54fe41dcf74a
	)
endif()
if(key STREQUAL "windows-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win64.zip"
		FILENAME "slang-${VERSION}-win64.zip"
		SHA512 4bdb6917f8689036f7619a07f575b86a2bf10deb258d037399a434bc35e80c8a014f59914f5883a5cd55d5d3717b1ff54d583a63527e5f1cfed06864a15638bb
	)
endif()
if(key STREQUAL "windows-aarch64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win-arm64.zip"
		FILENAME "slang-${VERSION}-win-arm64.zip"
		SHA512 7d4371270af96a6d3072411c37e83804108e6dfbd6dcc58b4c750165c67a0df7094f9f9b61d9a32f2a7740484c9393b7ed03866d6e37407b126dc2fb441c3bf9
	)
endif()
if(key STREQUAL "macosx-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x64.zip"
		FILENAME "slang-${VERSION}-macos-x64.zip"
		SHA512 069fade467bfa0c58d25d4366070cb7e17f64f96e8a3c873e69435f52b688660b4f4da51c99266fc6ca1765f1e3fde8e3bb719cccd9c6a2407bfa8468dc6c724
	)
endif()
if(key STREQUAL "macosx-aarch64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
		FILENAME "slang-${VERSION}-macos-aarch64.zip"
		SHA512 d4f2ef7f0c90297eb97e772860cb2cc4cb8beb81ea36aa0d488364bb4e78cd5c98c455168daa5cf03fa7b295f212b0d49a66a7de3ae385fe5c22ddb471d282ae
	)
endif()
if(key STREQUAL "linux-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.zip"
		FILENAME "slang-${VERSION}-linux-x86_64.zip"
		SHA512 d6b03a7c35218324d85ac478470e8ba5ffea49703f601202cd04e837c9ffddf5461ee954bde324f71fd3e400bcd2bb637d1dbbbefd2418b7e0f80013c0ff6bed
	)
endif()
if(key STREQUAL "linux-aarch64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64.zip"
		FILENAME "slang-${VERSION}-linux-aarch64.zip"
		SHA512 68f7912aa0c8280f0ce872ecfdfbb509de66573bc4d0f9c50843f74d5070e62d58556044a7f1dbff57d06017b0b8886452af23671a597f712aa4bf913a100baa
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
		SHA512 599924333c41c2ee0497d1bfc59b9daefe6f05d43aef96cfba64ec819c8da8fab89c8bfa15bc52ce7c014919c0b87997094489a3dfacee8ecbab1c7d8909f462
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
