# The engine itself ships as a prebuilt shared library.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openpitkit/pit
  REF "v0.12.0"
  SHA512 b0b15eb0042b71211317a8b0568b8963ec7d0fdaaa6225bcd7e888f4b5cecf8a1f944eab0d24051bc5d3c210bd2cf3002a0e75bd19dbfffe9bb54e8ea7eb8de4)

# Select the engine for the target triplet and supply it to both the package
# build and the exported config.
if(VCPKG_TARGET_IS_WINDOWS)
  if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR
      "openpit: no prebuilt engine for windows-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
  set(openpit_runtime_asset "openpit-ffi--windows-amd64-openpit_ffi.dll")
  set(openpit_runtime_sha512 "49124cc245b7f095b8f4c8a88d8e532ac4a869897910835bcafceebfabfaf03f74db7c4ff839ca92189dadb44e9d898d245a9b68bec7b0a7a3d1e1062e6e57eb")
  set(openpit_runtime_file "openpit_ffi.dll")
  set(openpit_implib_asset "openpit-ffi--windows-amd64-openpit_ffi.dll.lib")
  set(openpit_implib_sha512 "fa1358fa833667753aa8f25ddf4b11ff4c68f282dc2341bc008fae9bf815474a370ee3248086fc465fe76ec8b00b14e2d3eb6c16f2afb5b534eed0bef7cf00b5")
  set(openpit_implib_file "openpit_ffi.lib")
elseif(VCPKG_TARGET_IS_OSX)
  set(openpit_runtime_file "libopenpit_ffi.dylib")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--darwin-arm64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "668eec0dfbfaff1b52b397d060056848e64dc3966a5e468e4848333176827c3b831236bf8e2a29bdb8083b99bcde91adb48651aefd2ef3c298941b32239b8cb9")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--darwin-amd64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "5c5a53d7b13f301c6f95a03f5a8437052a4fb02c278ba765ea815714f392c53cd817c68fe04f9968970010a1f68e738da66efc7a8c556a7434e621edd2398b72")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for osx-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  set(openpit_runtime_file "libopenpit_ffi.so")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--linux-arm64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "dfbc58403160fe221fddfbcf9e9baabf9c81681418edfd4c9c4b315c57c6ccb0012a375650f53848175bfc28040f4760a8dad0676d1402e5182d084c5283c7b2")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--linux-amd64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "7eb050a143e91eab082a278944b7e2d422cb88edbf37d965623eea3332a877bac839e051ff40fdc074bea17528c390cc207714c9fc3e3432b04a9d8a49d20d33")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for linux-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
else()
  message(FATAL_ERROR "openpit: unsupported target platform")
endif()

vcpkg_download_distfile(openpit_runtime_path
  URLS "https://github.com/openpitkit/pit/releases/download/v0.12.0/${openpit_runtime_asset}"
  FILENAME "openpit-${VERSION}-${openpit_runtime_asset}"
  SHA512 "${openpit_runtime_sha512}")

set(openpit_runtime_options
  "-DOPENPIT_RUNTIME_LIBRARY=${openpit_runtime_path}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_download_distfile(openpit_implib_path
    URLS "https://github.com/openpitkit/pit/releases/download/v0.12.0/${openpit_implib_asset}"
    FILENAME "openpit-${VERSION}-${openpit_implib_asset}"
    SHA512 "${openpit_implib_sha512}")
  list(APPEND openpit_runtime_options
    "-DOPENPIT_RUNTIME_IMPORT_LIBRARY=${openpit_implib_path}")
endif()

# The C++ layer is a header-only wrapper around the C ABI, so one
# configuration of its CMake package covers every consumer. The package
# installs the engine it was given and exports it from its own config.
block(SCOPE_FOR VARIABLES)
  set(VCPKG_BUILD_TYPE release)
  vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/bindings/cpp"
    OPTIONS
      ${openpit_runtime_options}
      "-DOPENPIT_BUNDLE_RUNTIME=ON"
      "-DOPENPIT_CPP_BUILD_TESTS=OFF"
      "-DOPENPIT_CPP_CHECK_HEADERS=ON"
      "-DOPENPIT_PACKAGE_VERSION=0.12.0"
      "-DOPENPIT_RUNTIME_VERSION=0.12.0")
  vcpkg_cmake_install()
  vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenPit)
endblock()

# The engine is released in one flavour: it links its C runtime statically,
# and nothing CRT-owned crosses its C ABI, so the same binary serves Debug
# consumers. A triplet that builds both configurations gets it under debug/
# as well.
if(NOT VCPKG_BUILD_TYPE)
  if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${openpit_runtime_file}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/lib/${openpit_implib_file}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  else()
    file(INSTALL "${CURRENT_PACKAGES_DIR}/lib/${openpit_runtime_file}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()
endif()

vcpkg_install_copyright(FILE_LIST
  "${SOURCE_PATH}/LICENSE"
  "${SOURCE_PATH}/THIRD-PARTY-LICENSES")
