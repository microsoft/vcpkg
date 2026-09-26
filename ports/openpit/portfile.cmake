# The engine itself ships as a prebuilt shared library.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
# The engine library is code-signed and already carries an @rpath install
# name. Rewriting its load commands would break the signature, and arm64
# macOS refuses to load a library whose signature is broken.
set(VCPKG_FIXUP_MACHO_RPATH OFF)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openpitkit/pit
  REF "v0.8.1"
  SHA512 55fac6e56af7b876c84de0017d1b986b1606e5442ade5232aa7bbfd78236ab94efaa473172789c2dec5058f7db4e13f3e777c5744f9bd409a49ff1eb7a6b91fc)

# Select the engine for the target triplet and supply it to both the package
# build and the exported config.
if(VCPKG_TARGET_IS_WINDOWS)
  if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR
      "openpit: no prebuilt engine for windows-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
  set(openpit_runtime_asset "openpit-ffi--windows-amd64-openpit_ffi.dll")
  set(openpit_runtime_sha512 "6383f9692131c0f9279b9dd259a9741267e85155b19242509fff79e6abc2c07101a093a7bc2e3b63e922017b89666beb175d69ab397b84e8122e2ebc47448c42")
  set(openpit_runtime_file "openpit_ffi.dll")
  set(openpit_implib_asset "openpit-ffi--windows-amd64-openpit_ffi.dll.lib")
  set(openpit_implib_sha512 "348b876fb0378eb2fb785b40f6a134b3e6c171c4943c7bb4a738653cf0523e7b91ba393f30f7deb937227167368ba69ffa2728563dc64e70c29507169fc2c162")
  set(openpit_implib_file "openpit_ffi.lib")
elseif(VCPKG_TARGET_IS_OSX)
  set(openpit_runtime_file "libopenpit_ffi.dylib")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--darwin-arm64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "d8d66f6cb9f91c2299c9f5a7e24151b6d3dbeefe8b5ac4780b1e0f71053859b622a7beba72a5b8db7e061c12daf94b1a50ab97a86d4d70a299309433fe427a57")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--darwin-amd64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "0d86233879cf62e8c5cce1910191eca5d506c075a5a0ee0896753b4300a4a017d87f67e425b82cfeb3cf2f19acb8cb3b315d8231bd129efa99cef284d3d8f1ec")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for osx-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  set(openpit_runtime_file "libopenpit_ffi.so")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--linux-arm64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "d60fbd3bc66e14ddbfe6f13b33da55b2c38a8eabe36fcc0e17f1c49c64c0ccb245c34d4a1815b1c6fcb2d9114a98ac376a434b91495c7cc6d5527525eda3e980")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--linux-amd64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "136a5af1554cd5bd1e3d4250498d380d4025e4b9d45b49d891d4ff4043502d1d49b368428e633c0ddce9b9f5c93f6fc5653b06e2e62e249b0f26b26d1617ac80")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for linux-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
else()
  message(FATAL_ERROR "openpit: unsupported target platform")
endif()

vcpkg_download_distfile(openpit_runtime_path
  URLS "https://github.com/openpitkit/pit/releases/download/v0.8.1/${openpit_runtime_asset}"
  FILENAME "openpit-${VERSION}-${openpit_runtime_asset}"
  SHA512 "${openpit_runtime_sha512}")

set(openpit_runtime_options
  "-DOPENPIT_RUNTIME_LIBRARY=${openpit_runtime_path}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_download_distfile(openpit_implib_path
    URLS "https://github.com/openpitkit/pit/releases/download/v0.8.1/${openpit_implib_asset}"
    FILENAME "openpit-${VERSION}-${openpit_implib_asset}"
    SHA512 "${openpit_implib_sha512}")
  list(APPEND openpit_runtime_options
    "-DOPENPIT_RUNTIME_IMPORT_LIBRARY=${openpit_implib_path}")
endif()

# The C++ layer is a header-only wrapper around the C ABI, so one
# configuration of its CMake package covers every consumer.
block(SCOPE_FOR VARIABLES)
  set(VCPKG_BUILD_TYPE release)
  vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/bindings/cpp"
    OPTIONS
      ${openpit_runtime_options}
      "-DOPENPIT_CPP_BUILD_TESTS=OFF"
      "-DOPENPIT_PACKAGE_VERSION=0.8.1"
      "-DOPENPIT_RUNTIME_VERSION=0.8.1")
  vcpkg_cmake_install()
  vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenPit)
endblock()

# The engine is released in one flavour. A triplet that builds both
# configurations gets the same binary under debug/ as well, so Debug consumers
# link and deploy it too.
set(openpit_install_prefixes "${CURRENT_PACKAGES_DIR}")
if(NOT VCPKG_BUILD_TYPE)
  list(APPEND openpit_install_prefixes "${CURRENT_PACKAGES_DIR}/debug")
endif()
if(VCPKG_TARGET_IS_WINDOWS)
  set(openpit_runtime_dir "bin")
else()
  set(openpit_runtime_dir "lib")
endif()
foreach(openpit_install_prefix IN LISTS openpit_install_prefixes)
  file(INSTALL "${openpit_runtime_path}"
    DESTINATION "${openpit_install_prefix}/${openpit_runtime_dir}"
    RENAME "${openpit_runtime_file}")
  if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${openpit_implib_path}"
      DESTINATION "${openpit_install_prefix}/lib"
      RENAME "${openpit_implib_file}")
  endif()
endforeach()

# Point the exported config at the engine this port just installed. The
# resolver returns on the first branch when the path is set, so a consumer
# never reaches for a release asset. The config lives in share/${PORT}, hence
# two levels up.
set(openpit_config_file
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenPitConfig.cmake")
file(READ "${openpit_config_file}" openpit_config_contents)
string(FIND "${openpit_config_contents}" "openpit_resolve_runtime()"
  openpit_resolver_call)
if(openpit_resolver_call EQUAL -1)
  message(FATAL_ERROR
    "openpit: OpenPitConfig.cmake no longer calls openpit_resolve_runtime(), "
    "so the installed engine cannot be wired into the package config")
endif()
set(openpit_config_prelude
  "set(OPENPIT_RUNTIME_LIBRARY \"\${CMAKE_CURRENT_LIST_DIR}/../../${openpit_runtime_dir}/${openpit_runtime_file}\")")
if(VCPKG_TARGET_IS_WINDOWS)
  string(APPEND openpit_config_prelude
    "\nset(OPENPIT_RUNTIME_IMPORT_LIBRARY \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/${openpit_implib_file}\")")
endif()
set(openpit_config_runtime "${openpit_config_prelude}\nopenpit_resolve_runtime()")
if(VCPKG_TARGET_IS_LINUX)
  # The release ELF has no SONAME. Link by the installed library name so that
  # consumers do not embed the absolute package path in DT_NEEDED.
  string(APPEND openpit_config_runtime
    "\nset_target_properties(OpenPit::runtime PROPERTIES IMPORTED_NO_SONAME TRUE)")
endif()
vcpkg_replace_string("${openpit_config_file}"
  "openpit_resolve_runtime()"
  "${openpit_config_runtime}")

vcpkg_install_copyright(FILE_LIST
  "${SOURCE_PATH}/LICENSE"
  "${SOURCE_PATH}/THIRD-PARTY-LICENSES")
