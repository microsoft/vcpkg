vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(key NOTFOUND)
if(VCPKG_TARGET_IS_WINDOWS)
	set(key "windows-${VCPKG_TARGET_ARCHITECTURE}")
elseif(VCPKG_TARGET_IS_OSX)
	set(key "macosx-${VCPKG_TARGET_ARCHITECTURE}")
elseif(VCPKG_TARGET_IS_LINUX)
	set(key "linux-${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(ARCHIVE NOTFOUND)
# For convenient updates, use 
# vcpkg install shader-slang --cmake-args=-DVCPKG_SHADER_SLANG_UPDATE=1
if(key STREQUAL "windows-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-x86_64.zip"
		FILENAME "slang-${VERSION}-windows-x86_64.zip"
		SHA512 b1af26beb786b2f47bb4dc4e94613c9dda61f6c26539917376d13252ddcbed925f5b1f82948012d2cd288a20ea9d27f3703db96bc8b6689f69ac9f3e3a673584
	)
endif()
if(key STREQUAL "windows-arm64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64.zip"
		FILENAME "slang-${VERSION}-windows-aarch64.zip"
		SHA512 8c9f8082dd949d10d4228ce5d58cf862c9419039f7e5fdde3719f9ea446e55a87eb3e6f8367d26e0015830951c98175d1e59e95873cac9e937f98a6c8d211c16
	)
endif()
if(key STREQUAL "macosx-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64.zip"
		FILENAME "slang-${VERSION}-macos-x86_64.zip"
		SHA512 88a920f44650bc99ed97b04d3d674fd256b1414c60697dee7bc234472abe9216d7a3d3e5b75537fe01f7da56fe1fe5348d2cd38dad43f4f143105e4cb2e1ec53
	)
  vcpkg_download_distfile(
    TOOL_ARCHIVE
      URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-macos-dist-x86_64.zip"
      FILENAME "slang-macos-dist-x86_64.zip"
      SHA512 1b375c4ef24e74b3a11d79333081fc1154cd0273a017ea4983185eb9877f56e83e651dcd9e835ca9be0e90bc652fc6d9a965ac43d45cac4bc43bb5892cfcd652
    )
endif()
if(key STREQUAL "macosx-arm64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
		FILENAME "slang-${VERSION}-macos-aarch64.zip"
		SHA512 f3de6277d06a9aaadffe4e3d7d74a2352edc12001055142682eb65834cedfdea8f37daa65b7719178a4419f7e87842de6814c03a68b843c5c0085239bb895058
	)
  vcpkg_download_distfile(
		TOOL_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-macos-dist-aarch64.zip"
		FILENAME "slang-macos-dist-aarch64.zip"
		SHA512 1f05918650bcbe68981810f9b0c286fbead709b9b13e4356006d894b3f7651160168d5e28ab422d35c1c370e620029220b901b373196cd0f3b0240468f5a80cf
	)
endif()
if(key STREQUAL "linux-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.zip"
		FILENAME "slang-${VERSION}-linux-x86_64.zip"
		SHA512 7db8c2635bd5868a6741c1e094b7b2f6a095b66f1314c811e6fd41fc198ef68c7700214d9e81db80615daadd2bb89e2a6169d8cb6da5f2185bafdcff43d581b8
	)
endif()
if(key STREQUAL "linux-arm64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64.zip"
		FILENAME "slang-${VERSION}-linux-aarch64.zip"
		SHA512 5c7bc8a9fe3d7c3829434469833f4c1aa70160914d80ac5292ef115cb0a9c8a0907f9f49488b5d14bd2668bf5d3420ccad289aa4f02c6d673e492b548fd9f4e9
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

# On macos we need to download and copy tools slightly different due to code-signing reasons
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
  if(NOT TOOL_ARCHIVE)
    message(FATAL_ERROR "Failed to retrieve relocatable macos executables.")
  endif()
  vcpkg_extract_source_archive(
    TOOL_BINDIST_PATH
    ARCHIVE "${TOOL_ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
  )
endif()

if(VCPKG_SHADER_SLANG_UPDATE)
	message(STATUS "All downloads are up-to-date.")
	message(FATAL_ERROR "Stopping due to VCPKG_SHADER_SLANG_UPDATE being enabled.")
endif()

file(GLOB libs
	"${BINDIST_PATH}/lib/*.lib"
	"${BINDIST_PATH}/lib/*.dylib"
	"${BINDIST_PATH}/lib/*.so"
)
file(INSTALL ${libs} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(GLOB dyn_libs
	"${BINDIST_PATH}/lib/*.dylib"
	"${BINDIST_PATH}/lib/*.so"
)

if(VCPKG_TARGET_IS_WINDOWS)
  file(GLOB dlls "${BINDIST_PATH}/bin/*.dll")
  list(APPEND dyn_libs ${dlls})
  file(INSTALL ${dlls} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

if(NOT VCPKG_BUILD_TYPE)
  file(INSTALL "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
  endif()
endif()

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
  # Important to remove existing files
  # Otherwise we will run afoul of code signature
  file(GLOB existing "${CURRENT_PACKAGES_DIR}/tools/shader-slang/*")
  if(existing)
    file(REMOVE ${existing})
  endif()
  file(GLOB osx_tools "${TOOL_BINDIST_PATH}/*")
  file(INSTALL ${osx_tools} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/shader-slang")
else()
  # Must manually copy some tool dependencies since vcpkg can't copy them automagically for us
  file(INSTALL ${dyn_libs} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/shader-slang")
  vcpkg_copy_tools(TOOL_NAMES slangc slangd SEARCH_DIR "${BINDIST_PATH}/bin")
endif()

file(GLOB headers "${BINDIST_PATH}/include/*.h")
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
