# The engine itself ships as a prebuilt shared library.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openpitkit/pit
  REF "v0.8.3"
  SHA512 183ddb1929984a99ceaac04870096da6b354efbc87022cdb2f52704bfce9ce5eb3faf51aaa46824cc402c9ca020bced2df61ea930e1f298e35da61ee139330de)

# Select the engine for the target triplet and supply it to both the package
# build and the exported config.
if(VCPKG_TARGET_IS_WINDOWS)
  if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR
      "openpit: no prebuilt engine for windows-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
  set(openpit_runtime_asset "openpit-ffi--windows-amd64-openpit_ffi.dll")
  set(openpit_runtime_sha512 "d0f76b4afaf3e6f26328be374bf049344ead833faaf1c2379f1aa70adb2ab78eeb5e87054ff0d7ddaa495a9f5805541ef5c2bef0333a5b1212b4daa358b99147")
  set(openpit_runtime_file "openpit_ffi.dll")
  set(openpit_implib_asset "openpit-ffi--windows-amd64-openpit_ffi.dll.lib")
  set(openpit_implib_sha512 "348b876fb0378eb2fb785b40f6a134b3e6c171c4943c7bb4a738653cf0523e7b91ba393f30f7deb937227167368ba69ffa2728563dc64e70c29507169fc2c162")
  set(openpit_implib_file "openpit_ffi.lib")
elseif(VCPKG_TARGET_IS_OSX)
  set(openpit_runtime_file "libopenpit_ffi.dylib")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--darwin-arm64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "917419411156b31380b40ec90c04a362a5d20a72777017cd9842bf2b1df81486b0c590e91e107a4ed8e78f0751601f236744c9b44c796b987aa9e3e647cc84ec")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--darwin-amd64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "469f0da90ff7a366f5febdab7d0c4ba79f22e4e3b7eb03da5a4ac217baa44745fb56655bdf272f1499a88211ecdfc203e5c55a10439dba9b0b535862b3ab4965")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for osx-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  set(openpit_runtime_file "libopenpit_ffi.so")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--linux-arm64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "fd4bc70b9c49cb472d644ecb6dfccbbec1d3d254ffce643db761a05b02d6d1e3718ce012086fed183db3d73c6060e97e312018372a89fed4694329ad95f5ee05")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--linux-amd64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "88472e05eb0b8169d793a9aa7efc7a3b279c7dda6774a28ecff9da306b2d67ce29d2b61a58b0ae1489f869220237e5e84a280c751822ee413e2491ac3e8f8365")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for linux-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
else()
  message(FATAL_ERROR "openpit: unsupported target platform")
endif()

vcpkg_download_distfile(openpit_runtime_path
  URLS "https://github.com/openpitkit/pit/releases/download/v0.8.3/${openpit_runtime_asset}"
  FILENAME "openpit-${VERSION}-${openpit_runtime_asset}"
  SHA512 "${openpit_runtime_sha512}")

set(openpit_runtime_options
  "-DOPENPIT_RUNTIME_LIBRARY=${openpit_runtime_path}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_download_distfile(openpit_implib_path
    URLS "https://github.com/openpitkit/pit/releases/download/v0.8.3/${openpit_implib_asset}"
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
      "-DOPENPIT_PACKAGE_VERSION=0.8.3"
      "-DOPENPIT_RUNTIME_VERSION=0.8.3")
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
