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
		SHA512 cdd3329697a7307e0e46a03c45f279af9dd437cf842829f7dee579408959bd821982d9a486a4b01b865b19e67292c378ee962d340244c3062a3915b4f2cb967d
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-windows-x86_64-debug-info.zip"
		SHA512 3ae219e7e967e3fb1fddd5bb15259b3093667b043f1d644abcfaa39f7d52e415ecd2a8dcfbb600041cc7d7454b8da092baea8c74858080fd18599123ed23c447
	)
endif()
if(key STREQUAL "windows-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64.zip"
		FILENAME "slang-${VERSION}-windows-aarch64.zip"
		SHA512 bbfc7aea87a2f1409adab9a89080e29f487f12b2869e257318a09d10d02c1f0debcbe8681b5f20bf0a8334e80e9349380e387ef11f0f7eb9014f3fbaf67c2dd7
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-windows-aarch64-debug-info.zip"
		SHA512 94ba9a0245be873f4ef96c8d8cc15bf94578402a4c69d56ba8bd1d00cd9b070af5c49fa2be2b2d745c219ade8285ea8235aa7043c94df7d4e01ff4b95621d228
	)
endif()
if(key STREQUAL "macosx-x64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64.zip"
		FILENAME "slang-${VERSION}-macos-x86_64.zip"
		SHA512 565656ef017ea84c164c1e1195d6a7f9e0a63731f6589c2b4eddb51b14b0ee071815c448d6f84451fa8e29b8c6d0e6a509f0eb7a59ef16b0216ce9c6d1049bc5
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-macos-x86_64-debug-info.zip"
		SHA512 ac798bc3bcf7dc906944fba0d2ae122e651980c48f89461768ab91436470b9b8f0111c73ffd4e295607525065666218bac256347315d3fe6a191d9096f7794f6
	)
endif()
if(key STREQUAL "macosx-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
		FILENAME "slang-${VERSION}-macos-aarch64.zip"
		SHA512 8b68493520bb0f42ffc9a269d1a28334b5e079b523558df9387ddf8d7e8268f0e1cfe4f5e4f6984d947bb6cbd5680d2663dc689c113ac890c141e87302b9dc0c
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-macos-aarch64-debug-info.zip"
		SHA512 a6ef253e2d6383d8385bebb48396d91af0ad28d659ba2c957e6bfa643ff81de2cd2a9cf0c2ab2216a3e8aadf2ec22519559598b68f626ada264edf1bd207b3c7
	)
endif()
if(key STREQUAL "linux-x64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.zip"
		FILENAME "slang-${VERSION}-linux-x86_64.zip"
		SHA512 363dd468097822de6f140ecea99c7d15b1b262ce431cea3d5afed186c27055298681e4b2c46c9078e8f2bed0627a9a0e597694bad75e15e707833c9e4be516d1
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-linux-x86_64-debug-info.zip"
		SHA512 16de664d0e48e51c5d4d449edcaefc7767442275060cd6c8b1aed957554ceb37ab34bf52012783d0d7f7361906c7a57250caaae23f096dee886d1499336b862c
	)
endif()
if(key STREQUAL "linux-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64.zip"
		FILENAME "slang-${VERSION}-linux-aarch64.zip"
		SHA512 275563e15bd317aeb785efcbffad7898e1bee27681342ea5d591a13be1f23bdd6acf7bead2f7cb89dfdd91f8788c381f764d247e519863d88e61536bb531f40e
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-linux-aarch64-debug-info.zip"
		SHA512 ba54fb78460cffe64b641cc2c67910fec4cb09f166f0da047d57eda68abb7a185c2dab397afe90b9c46051e72bb9779d69e22076e5503a9909335353f2856076
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
