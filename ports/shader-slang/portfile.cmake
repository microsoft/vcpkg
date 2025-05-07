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
		SHA512 038449a2488e5f3296233355745e71c0efb30d1969a3180ecb5a6f3f5fa5fae245f7ba8b0d8919c88e09ab36e9f6f1d97bc681c4b8854f1b37f05707cdbf32c2
	)
endif()
if(key STREQUAL "windows-arm64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64.zip"
		FILENAME "slang-${VERSION}-windows-aarch64.zip"
		SHA512 45457e8d9214ca7ca430f48c0a0e473b7b99c64e0eb0abf1df6b5b4e355bee10c0d25af6be36892b40feee87dcb1a97849fe27c6089fd950b47f35aa65b7f101
	)
endif()
if(key STREQUAL "macosx-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64.zip"
		FILENAME "slang-${VERSION}-macos-x86_64.zip"
		SHA512 8e82df60633d4f746ed215276df23f78f811d4eb173e143d514f0ac2bae0d0a2da5c3d8c91fd36ed7d8cb23931e8b166a28598c45eb7c68a76e4396196aa2958
	)
endif()
if(key STREQUAL "macosx-arm64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
		FILENAME "slang-${VERSION}-macos-aarch64.zip"
		SHA512 d0d38766153ba0cd9e054228e24974f8620f493190dfe6304e70196bc0fc3455e1e70852501d8e00e14d5ffd99f1f1467879186f9b5d7593042b3f80f591535e
	)
endif()
if(key STREQUAL "linux-x64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.zip"
		FILENAME "slang-${VERSION}-linux-x86_64.zip"
		SHA512 8be4ddead8dbea3584e14e4b1faaaf3ba1a0bf69720134f39c88430dc4e8116f7678de116ec12a76c40133c1725b787103ed35075f6e42ca7a3a26be5c53f03e
	)
endif()
if(key STREQUAL "linux-arm64" OR VCPKG_SHADER_SLANG_UPDATE)
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64.zip"
		FILENAME "slang-${VERSION}-linux-aarch64.zip"
		SHA512 180ce479f8aee8735729d0df6a7569f54f82abad425dca07e310c0997e3b4fd95dd001bfa8fb181384abf779c7616317ad34339de679f9f48ba6ee9f1554cd75
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

if(VCPKG_SHADER_SLANG_UPDATE)
	message(STATUS "All downloads are up-to-date.")
	message(FATAL_ERROR "Stopping due to VCPKG_SHADER_SLANG_UPDATE being enabled.")
endif()

file(GLOB slang_cmake_configs
		"${BINDIST_PATH}/cmake/*.cmake"
)

# install cmake files
set(SLANG_INSTALL_CMAKE_PATH "${CURRENT_PACKAGES_DIR}/share/slang")
file(INSTALL ${slang_cmake_configs} DESTINATION "${SLANG_INSTALL_CMAKE_PATH}")

# Redirect CURRENT_PACKAGES_DIR from '/share' to '/share/slang'
file(READ "${SLANG_INSTALL_CMAKE_PATH}/slangTargets.cmake" _contents)
STRING(REPLACE "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)" "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)" _contents "${_contents}")
file(WRITE "${SLANG_INSTALL_CMAKE_PATH}/slangTargets.cmake" "${_contents}")

# Redirect the installation directory of the executable files from 'bin' to 'tools'
file(READ "${SLANG_INSTALL_CMAKE_PATH}/slangTargets-release.cmake" _contents)
STRING(REPLACE "\${_IMPORT_PREFIX}/bin/slangc" "\${_IMPORT_PREFIX}/tools/slang/slangc" _contents "${_contents}")
STRING(REPLACE "\${_IMPORT_PREFIX}/bin/slangd" "\${_IMPORT_PREFIX}/tools/slang/slangd" _contents "${_contents}")
file(WRITE "${SLANG_INSTALL_CMAKE_PATH}/slangTargets-release.cmake" "${_contents}")


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
  file(INSTALL "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
  if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
  endif()
endif()

# On macos, slang has signed their binaries
# vcpkg wants to be helpful and update the rpath as it moves binaries around but this 
# breaks the code signature and makes the binaries useless
# Removing the signature is rude so instead we will disable rpath fixup
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
  set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()

vcpkg_copy_tools(TOOL_NAMES slangc slangd SEARCH_DIR "${BINDIST_PATH}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/slang")

file(GLOB headers "${BINDIST_PATH}/include/*.h")
file(INSTALL ${headers} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
	FILE_LIST "${BINDIST_PATH}/LICENSE"
	COMMENT #[[ from README ]] [[
The Slang code itself is under the Apache 2.0 with LLVM Exception license.

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
