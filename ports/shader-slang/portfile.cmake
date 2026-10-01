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
		SHA512 91832d83d2372bb59d3460f58b369c39442758467a58aa24e01da4ae73a40c106adf2cff2f49459bce81b759a6e256ba35d66ecf48fc74cf0fe5d9d7f11e4354
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-windows-x86_64-debug-info.zip"
		SHA512 602e6011aa7220b4d3ee56ad8b28e4b2570491a02dd45044c97fc6c14fb2fe24912e60988947e7381857b8a7e11411f6048685ce84e489cedb3f6464846354c6
	)
endif()
if(key STREQUAL "windows-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64.zip"
		FILENAME "slang-${VERSION}-windows-aarch64.zip"
		SHA512 025a2bd1b342dcad4d6fd52479c70b96d7376d89da9eb1ca1202132bdfd3cf9b9e0b60b67f074947565775ab490d86bc4382768ac572afe7ae6bd118c73279a9
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-windows-aarch64-debug-info.zip"
		SHA512 9032efc0c77116f514427ea5066eb8e9540efc23388bba51d4ed9683f6008e65f853625510d558dfb6f09887317638e1103f0d066c20df2f98c2cc28e0aab33b
	)
endif()
if(key STREQUAL "macosx-x64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64.zip"
		FILENAME "slang-${VERSION}-macos-x86_64.zip"
		SHA512 c957c9b0ac4730ecfdf214ec986626e21ecce8e7b31b466f5afff9730b887f6d575d966d3d9c9b2f26010201963034dddc51457dcee5cc4949e5c3a039b96dc8
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-macos-x86_64-debug-info.zip"
		SHA512 8d5e811feaf336a5b00c59e1abbb42fc2b2b20752422dbc9cc5427122e534e36e2d33a83b79b4d49530e3b9991985aaf9cc64e693610220d610fd2dc36b3e2c2
	)
endif()
if(key STREQUAL "macosx-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
		FILENAME "slang-${VERSION}-macos-aarch64.zip"
		SHA512 40de6d1fe1b2b63b1650a1fb2d8555a4108b9ffba665f9436691926ababa809186774494521eb1aea8b3ac62fd4b50396aa2ee9e6ccda8f06ef16f18113bc641
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-macos-aarch64-debug-info.zip"
		SHA512 cf3aa327183c6762842e10a6cd386f442aed9ffa823d564c471f020c0139b77f664a7ddc988e9c1b84d73b534fc051baa332ab7be136017dd2da656a8a0bbe2d
	)
endif()
if(key STREQUAL "linux-x64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.zip"
		FILENAME "slang-${VERSION}-linux-x86_64.zip"
		SHA512 76c2c8b8cd4ff21ac433f1f14895365d4cf7dcad25a5e5c2f091e87673db2716e22eedd175b1e884272f14aab0abdefbcf36beff05e9e9a93f07dc4c8a4fb5d2
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-linux-x86_64-debug-info.zip"
		SHA512 ac52c29728035d72c82d5e1dc143c31ced949ccd21ee465421155017480194dc767114328520ee73ca4ac4d23e6d82c6f0b52d9b4e2b21aa144115b802d88a64
	)
endif()
if(key STREQUAL "linux-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64.zip"
		FILENAME "slang-${VERSION}-linux-aarch64.zip"
		SHA512 1cc39af654570ab9ae1605b32afde198526d4dbf5ad4859fb5c1f5159c2cedcf98b44be6ef84bf1f3495d60b15fb78c46a0a6bda1e261da6997851a1ba6f35e9
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-linux-aarch64-debug-info.zip"
		SHA512 363d98ffa1444785dc7e6122418767b3bd47c3598e2af53541b7b559cb7d764c006c991a9b78ff8a631a2a6c8bcc52f879b369cf52177f6c20c02ed9ceca9daf
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

vcpkg_install_copyright(
	FILE_LIST
		"${BINDIST_PATH}/LICENSE"
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
