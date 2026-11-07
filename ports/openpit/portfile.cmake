# The engine itself ships as a prebuilt shared library.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openpitkit/pit
  REF "v0.11.0"
  SHA512 951db123513f27f3504e233431fbba24ec62ee0fd30c0b51b1c2993ab0e6492acf4072e4a7985e27913c3990083438c0dc21f88cd99dde21beb2f3f290328756)

# Select the engine for the target triplet and supply it to both the package
# build and the exported config.
if(VCPKG_TARGET_IS_WINDOWS)
  if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR
      "openpit: no prebuilt engine for windows-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
  set(openpit_runtime_asset "openpit-ffi--windows-amd64-openpit_ffi.dll")
  set(openpit_runtime_sha512 "dcf2fceaa32f362bd8f3ef1f51b425a0c807e1b034ac8ac83ff83140a1ebb43082e9cf3cda070efbda75aeb32bead448bc78572dacac23350bdf3677a5ae7ea0")
  set(openpit_runtime_file "openpit_ffi.dll")
  set(openpit_implib_asset "openpit-ffi--windows-amd64-openpit_ffi.dll.lib")
  set(openpit_implib_sha512 "6d1a9fa8ac8f806caff402b8f40f59ad3dfa13157cf2ed5f33ddbd36ad7822469acccf92f574ab4fb8ce06db4184118ea78e1844092d5da6c1852bb861eb39c9")
  set(openpit_implib_file "openpit_ffi.lib")
elseif(VCPKG_TARGET_IS_OSX)
  set(openpit_runtime_file "libopenpit_ffi.dylib")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--darwin-arm64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "699dd64bb384186c7f50551312ef42e7d986123ce8ba4365b3506bac40bfe0138a420489790f499a42287c8b6ddca7ad958bb199c027d859d084230291a2af18")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--darwin-amd64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "f884631014a462e12610e425b0dc3f8dd78d1efb4708952a37de0b070811faeb9efa2f76ffccc7a91dbeca387e16ab3f3651379179ca1963a01ed3cd9fb78c8d")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for osx-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  set(openpit_runtime_file "libopenpit_ffi.so")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--linux-arm64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "af408adf7517f71756eb474c4a03988b66053af1e18a24cdf7625ffbd5e0bcbb99fbb4f07a9b32e4135dc3a356aa74f39a278cea02b4af82b7b6609c74ef8529")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--linux-amd64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "8c80af26694062ee7507ff31239ef65e0dfdd7dbcf87aa795298adf05e9e6c4fab928556f9daf63af27d7da01e6f40c9ad1640bd6c69a51fe4355046374e0af2")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for linux-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
else()
  message(FATAL_ERROR "openpit: unsupported target platform")
endif()

vcpkg_download_distfile(openpit_runtime_path
  URLS "https://github.com/openpitkit/pit/releases/download/v0.11.0/${openpit_runtime_asset}"
  FILENAME "openpit-${VERSION}-${openpit_runtime_asset}"
  SHA512 "${openpit_runtime_sha512}")

set(openpit_runtime_options
  "-DOPENPIT_RUNTIME_LIBRARY=${openpit_runtime_path}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_download_distfile(openpit_implib_path
    URLS "https://github.com/openpitkit/pit/releases/download/v0.11.0/${openpit_implib_asset}"
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
      "-DOPENPIT_PACKAGE_VERSION=0.11.0"
      "-DOPENPIT_RUNTIME_VERSION=0.11.0")
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
