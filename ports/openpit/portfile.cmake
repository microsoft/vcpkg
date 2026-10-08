# The engine itself ships as a prebuilt shared library.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openpitkit/pit
  REF "v0.9.0"
  SHA512 7a0c857ccf8fbf776bf59e6880def10e0207cf367414080bd3ff90fc7f9da76833e49c9a90efac603e0ad8265ec7858c0a605db68f0ff109d03c57089a7f1ca5)

# Select the engine for the target triplet and supply it to both the package
# build and the exported config.
if(VCPKG_TARGET_IS_WINDOWS)
  if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR
      "openpit: no prebuilt engine for windows-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
  set(openpit_runtime_asset "openpit-ffi--windows-amd64-openpit_ffi.dll")
  set(openpit_runtime_sha512 "c1dd654f337c31635fec883b37cac6aa7684042bde07550250e6fcf5722ba906767fff4894a0e2f1eaca3b5bca2c1ab9972fe170a36ff38ad23b592653b7861a")
  set(openpit_runtime_file "openpit_ffi.dll")
  set(openpit_implib_asset "openpit-ffi--windows-amd64-openpit_ffi.dll.lib")
  set(openpit_implib_sha512 "8447958468ef2516eafee4eb6b5715a14071bfa9c402f6140d7a03c91ff6b8bb60243bd7b7711ca6bf446a067ab25695edb5a27cc5f6295d397501714e641d5b")
  set(openpit_implib_file "openpit_ffi.lib")
elseif(VCPKG_TARGET_IS_OSX)
  set(openpit_runtime_file "libopenpit_ffi.dylib")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--darwin-arm64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "bb3ad3bf0093cb725ab3392fb8d9f3750edd1e1f7280b17437d6ffd041822b0ca12b33be3169c8bee40855356947e3b17c48ed7123114763f71d35e629aebfb6")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--darwin-amd64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "7d619f637b15698600ffdaaf8def4a62c03b815b1ca3e4d7d6782554a1993922564e166ddec9727f8b312598f781a2b2b412ea644c57e950e38a5d8c2683270c")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for osx-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  set(openpit_runtime_file "libopenpit_ffi.so")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--linux-arm64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "8514b74d5b2dd4556e369021095b50d730a47c0d19fc78620a64433fb8bae9d6a05a58a9669ee4eb610c632a6da48b868e9154bd86906e53ecdedada1f2ee6e8")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--linux-amd64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "d6f97e344bfd92925a4b10fb12766e8f69338d8c0b66105f777772e042a04d9243d872028c5281c189756dbdbbff4662e6d0f87a79ee04e2d857dc48e7c65178")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for linux-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
else()
  message(FATAL_ERROR "openpit: unsupported target platform")
endif()

vcpkg_download_distfile(openpit_runtime_path
  URLS "https://github.com/openpitkit/pit/releases/download/v0.9.0/${openpit_runtime_asset}"
  FILENAME "openpit-${VERSION}-${openpit_runtime_asset}"
  SHA512 "${openpit_runtime_sha512}")

set(openpit_runtime_options
  "-DOPENPIT_RUNTIME_LIBRARY=${openpit_runtime_path}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_download_distfile(openpit_implib_path
    URLS "https://github.com/openpitkit/pit/releases/download/v0.9.0/${openpit_implib_asset}"
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
      "-DOPENPIT_PACKAGE_VERSION=0.9.0"
      "-DOPENPIT_RUNTIME_VERSION=0.9.0")
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
