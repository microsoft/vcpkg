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
set(DEBUG_INFO_ARCHIVE NOTFOUND)
# For convenient updates, update the version in vcpkg.json
# and then run update_shas.py
if(key STREQUAL "windows-x64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-x86_64.zip"
		FILENAME "slang-${VERSION}-windows-x86_64.zip"
		SHA512 8f5bf4dd1bc0c6886f920445938c922f59b797b835b11b8c94727ceb01e24d2a4ac3b6cd090f4bfdcf7c787f6db074dd8582aad8db074aa042fffcf325d9de36
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-windows-x86_64-debug-info.zip"
		SHA512 8c06bbf5dc756e0eb7673347d7b2904dcfe17f7a1dc447b59230546dba5b33d642fd3db0ba6ec950e9ada271f4fa8018e021a2ce599db49465e41c49e53ee541
	)
endif()
if(key STREQUAL "windows-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64.zip"
		FILENAME "slang-${VERSION}-windows-aarch64.zip"
		SHA512 3a9a052df25319535de9f61f158411fd5a2006093132f71dda48c47c95120988d6ce995d9e9ee6d6ca683a414b68180bf6afedecbdf689d2c7502a40feec262c
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-windows-aarch64-debug-info.zip"
		SHA512 a9b4471d6614c1ee72a5ca38089d239a8e025541a129177c58133aa41a74d4b2764d958b89923eecbb1713f8f4c35d21d7ac3f24b816e066b14591b3cf81060f
	)
endif()
if(key STREQUAL "macosx-x64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64.zip"
		FILENAME "slang-${VERSION}-macos-x86_64.zip"
		SHA512 7736a0ed0c97244c43dea976803aff7988cea0d125d9f2980f5cc613df5acb662c11ed3b4ffabeb28df5025077fb02a52aa8faf7da4d8edb5362770ad8b55bca
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-macos-x86_64-debug-info.zip"
		SHA512 8cdadcb25c4871717ea4182659fcbcee317ff98539dc892c2b70d8ebaa10fdef1c419a7df07115a6f93ee8df17c45c2187177764ac3fce1cf30b718dce15f50e
	)
endif()
if(key STREQUAL "macosx-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
		FILENAME "slang-${VERSION}-macos-aarch64.zip"
		SHA512 7131736a8c6f92b142f2f8bc70bc9d2df54ea3ff117584dd5c61dee064dbd0dd8ae9b33804bee25d0e97518135f76cae247fdf3c343e23d8f9a46f522fcb0eea
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-macos-aarch64-debug-info.zip"
		SHA512 37839208a842358facd1580043f695ff8d80af245fd355412f426ddcef8672dadc90e6cd059fe64e426a146b2d307f30e0e5b2657a51fa861b15a8c37c460fcc
	)
endif()
if(key STREQUAL "linux-x64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.zip"
		FILENAME "slang-${VERSION}-linux-x86_64.zip"
		SHA512 7b88bca079e52b64a05d6d3b3d2d568b52cdd0d008d0f5aae28d2d64d89f819bf77e12fe51747fb262e8ebbda47087682d7c872c547194636a0a8263b05c4d84
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-linux-x86_64-debug-info.zip"
		SHA512 8aa699c86dc85c737cc28fc70c3efb132c90e674d745730cff10b4e773dc0cd4086e18e7dddc85c09e4b55bce55acc910f86d8afdbda7e2154ae5975c2e68318
	)
endif()
if(key STREQUAL "linux-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64.zip"
		FILENAME "slang-${VERSION}-linux-aarch64.zip"
		SHA512 28fe99c2aa1e6449364c889c054a33f09231e5e21e614110981b2de4de2e064a930c0904e0018a054dfe407c7659e0938dbc890539c107432cb53b954019f9ab
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-linux-aarch64-debug-info.zip"
		SHA512 f962af37f4f4a17bfc3a9a8c0d42f2e9da499e73212b64166ffbbb9893d62f193b8dda505e3e1dd56d9dd716bd160d0b96fb1eca466fce3360318b969da0b34a
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

if(DEBUG_INFO_ARCHIVE)
	vcpkg_extract_source_archive(
		DEBUG_INFO_PATH
		ARCHIVE "${DEBUG_INFO_ARCHIVE}"
		NO_REMOVE_ONE_LEVEL
	)
endif()

file(GLOB libs
	"${BINDIST_PATH}/lib/*.lib"
	"${BINDIST_PATH}/lib/*.dylib"
	"${BINDIST_PATH}/lib/*.so"
	"${BINDIST_PATH}/lib/*.so.0.${VERSION}" # On linux, some of the .so files are postfixed by the version.
)
file(INSTALL ${libs} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(GLOB dyn_libs
	"${BINDIST_PATH}/lib/*.dylib"
	"${BINDIST_PATH}/lib/*.so"
	"${BINDIST_PATH}/lib/*.so.0.${VERSION}" # On linux, some of the .so files are postfixed by the version.
)

if(VCPKG_TARGET_IS_WINDOWS)
  file(GLOB dlls "${BINDIST_PATH}/bin/*.dll")
  list(APPEND dyn_libs ${dlls})
  file(INSTALL ${dlls} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

  # In windows, the debug symbols are on the root directory of the debug archive
  if(DEBUG_INFO_PATH)
    file(GLOB pdb_files "${DEBUG_INFO_PATH}/*.pdb")
    if(pdb_files)
      file(INSTALL ${pdb_files} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    endif()
  endif()
endif()

# In other platfroms, the debug symbols are structured under lib.
# There are also debug symbols for the tools under bin but we ignore these
if(NOT VCPKG_TARGET_IS_WINDOWS AND DEBUG_INFO_PATH)
  file(GLOB debug_sym_libs "${DEBUG_INFO_PATH}/lib/*")
  if(debug_sym_libs)
    file(INSTALL ${debug_sym_libs} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  endif()
endif()

# The precompiled standard modules are looked up next to the slang runtime library
file(GLOB standard_modules
  "${BINDIST_PATH}/bin/slang-standard-module-*"
  "${BINDIST_PATH}/lib/slang-standard-module-*"
)
if(NOT standard_modules)
  message(FATAL_ERROR "No slang-standard-module-* directory found in the upstream archive.")
endif()
file(GLOB api_modules "${BINDIST_PATH}/bin/*.slang") # slang.slang and gfx.slang, the host API bindings
list(APPEND standard_modules ${api_modules})
if(VCPKG_TARGET_IS_WINDOWS)
  file(COPY ${standard_modules} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
else()
  file(COPY ${standard_modules} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
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

# Must manually copy some tool dependencies since vcpkg can't copy them automagically for us
file(INSTALL ${dyn_libs} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/shader-slang")
file(COPY ${standard_modules} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/shader-slang")
vcpkg_copy_tools(TOOL_NAMES slangc slangd slangi slang SEARCH_DIR "${BINDIST_PATH}/bin")

file(GLOB headers "${BINDIST_PATH}/include/*.h")
file(INSTALL ${headers} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

block(SCOPE_FOR VARIABLES)
	set(VCPKG_BUILD_TYPE Release) # no debug binaries anyways

	if (VCPKG_TARGET_IS_WINDOWS)
		file(COPY "${BINDIST_PATH}/cmake" DESTINATION "${CURRENT_PACKAGES_DIR}")
		vcpkg_cmake_config_fixup(CONFIG_PATH cmake PACKAGE_NAME slang)
	else()
		file(COPY "${BINDIST_PATH}/lib/cmake/slang" DESTINATION "${CURRENT_PACKAGES_DIR}")
		vcpkg_cmake_config_fixup(CONFIG_PATH slang PACKAGE_NAME slang)
	endif()

	vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/slang/slangConfig.cmake"
		[[HINTS "${PACKAGE_PREFIX_DIR}/bin" ENV PATH]]
		[[PATHS "${PACKAGE_PREFIX_DIR}/tools/shader-slang" NO_DEFAULT_PATH REQUIRED]]
	)
	vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/slang/slangConfigVersion.cmake"
		[[if("${CMAKE_SIZEOF_VOID_P}" STREQUAL ""]]
		[[if(#[=[ host tool ]=] "TRUE"]]
	)
endblock()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(GLOB third_party_notices LIST_DIRECTORIES false "${BINDIST_PATH}/third-party-notices/*")
vcpkg_install_copyright(
	FILE_LIST
		"${BINDIST_PATH}/LICENSE"
		${third_party_notices}
		"${BINDIST_PATH}/LICENSES/Apache-2.0.txt"
		"${BINDIST_PATH}/LICENSES/BSL-1.0.txt"
		"${BINDIST_PATH}/LICENSES/CC-BY-4.0.txt"
		"${BINDIST_PATH}/LICENSES/LicenseRef-UOI-NCSA.txt"
		"${BINDIST_PATH}/LICENSES/LLVM-exception.txt"
		"${BINDIST_PATH}/LICENSES/MIT.txt"
		"${BINDIST_PATH}/LICENSES/Unlicense.txt"
	COMMENT #[[ from README ]] [[
The Slang code itself is under the Apache 2.0 with LLVM Exception license.

Builds of the core Slang tools depend on the following projects, either automatically or optionally, which may have their own licenses:

* [`ankerl::unordered_dense::{map, set}`](https://github.com/martinus/unordered_dense) (MIT)
* [`fast_float`](https://github.com/fastfloat/fast_float) (Apache 2.0 / MIT / Boost)
* [`glslang`](https://github.com/KhronosGroup/glslang) (BSD)
* [`lz4`](https://github.com/lz4/lz4) (BSD)
* [`miniz`](https://github.com/richgel999/miniz) (MIT)
* [`spirv-headers`](https://github.com/KhronosGroup/SPIRV-Headers) (Modified MIT)
* [`spirv-tools`](https://github.com/KhronosGroup/SPIRV-Tools) (Apache 2.0)

Slang releases may include [LLVM](https://github.com/llvm/llvm-project) under the license:

* [`llvm`](https://llvm.org/docs/DeveloperPolicy.html#new-llvm-project-license-framework) (Apache 2.0 License with LLVM exceptions)
]])
