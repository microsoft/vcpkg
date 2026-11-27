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
		SHA512 453276a7227cb78d8786d2935d6e534365daf008339502d4952e33ebdb77f162b0d6e21c4fc8170d1dbbc9816a2b18787099c57e468de5566dc800709028a95e
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-windows-x86_64-debug-info.zip"
		SHA512 7a0269b6bed0e4926c68ebd70a138c254397c81cf0e1788b3f985d11eafe81c8c78ad00fb7b8e94c51125a5ed4a1d68496e2f1a8b8113ed4d51bb581dd581ee3
	)
endif()
if(key STREQUAL "windows-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64.zip"
		FILENAME "slang-${VERSION}-windows-aarch64.zip"
		SHA512 65df71a5d3ede105085e32c02b9dfa299bef35d35ddb7213284a6e751e4c28fbc110b9976b0cc6eefcf828c3f6e1600aad626fa5cd7e2216a580dfc75093c255
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-windows-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-windows-aarch64-debug-info.zip"
		SHA512 0eb4c4a87d11a5795b984c6369bf2626165152778e57836a58810f8ba44db2ba4062d13d777113bbfc2f4cced2b0d8259acd42163e7585599b5cac664b76fdd3
	)
endif()
if(key STREQUAL "macosx-x64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64.zip"
		FILENAME "slang-${VERSION}-macos-x86_64.zip"
		SHA512 fe8e15e880e8c85740d5d0a42c60a6b911fa9a6fbd98995feafb7a0b27621ff651154b40cc4fc3d96e5ca71fb47ad948b9ce88aab7d55916f66adc712d738b66
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-macos-x86_64-debug-info.zip"
		SHA512 d9be5fc383004c420ea1c68fbf2a8ba68219ebc777011f20111849357dce4829fd9a9e9046fde1b28d17af30377c3cfbb831661d1d868c1cd6d32a712e7e4f90
	)
endif()
if(key STREQUAL "macosx-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
		FILENAME "slang-${VERSION}-macos-aarch64.zip"
		SHA512 43d79f6e449d37c7d30b4ddfbeaf55b00445b2e68042ebb92f296248e666dd30a43efb063588fb5598317921a2e60f6fc14df196f3c813c0109fa889f2834620
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-macos-aarch64-debug-info.zip"
		SHA512 a91b291c0ea136d81edd8056a73ea5996059831fd755b909bae89ba8333a68b52b7f17c9463296d50171037e32c3e10f0f63eee359ee229db19372298a80d150
	)
endif()
if(key STREQUAL "linux-x64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.zip"
		FILENAME "slang-${VERSION}-linux-x86_64.zip"
		SHA512 446e0947b8774a35c4871b7ef0baf135a44267f3461fe952c83867710440ecec5c77cadf4589399aef7f11dbac19020a87793dcd420bec8b6c06ae2ff24b7ff3
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64-debug-info.zip"
		FILENAME "slang-${VERSION}-linux-x86_64-debug-info.zip"
		SHA512 d9613e4e179af63235540a937d9eb0d2bc188902678ca2beefb671fdc468e85e69897a6c9f7c6ec70f1831a8035af2b88249e154b0a1c09b52782f4522b7d30a
	)
endif()
if(key STREQUAL "linux-arm64")
	vcpkg_download_distfile(
		ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64.zip"
		FILENAME "slang-${VERSION}-linux-aarch64.zip"
		SHA512 583e407b143101b7bbba7c43272a175b7a579efce18e06e414aa770633e6434446428f32b4cf08680e4faef69de74a689713541584274db1a857ec3a5b0ed469
	)
	vcpkg_download_distfile(
		DEBUG_INFO_ARCHIVE
		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-aarch64-debug-info.zip"
		FILENAME "slang-${VERSION}-linux-aarch64-debug-info.zip"
		SHA512 5915583cbb202446e56316a379bf6d125638c2465b8efa575a2f0a0f88dcf14f4a028f1c9849812f0955e6803851d9ae6f6e7c24af17482a7ae1b46ec7a4d7d4
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
