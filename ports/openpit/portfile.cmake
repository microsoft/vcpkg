# Copyright The Pit Project Owners. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Please see https://openpit.dev and the OWNERS file for details.

# The C++ layer is a header-only wrapper around the C ABI, so a debug variant
# would build the same headers twice and install nothing extra.
set(VCPKG_BUILD_TYPE release)
# The engine itself ships as a prebuilt shared library.
set(VCPKG_LIBRARY_LINKAGE dynamic)
# That prebuilt engine is released in one flavour, so there is no debug binary
# to pair it with and nothing to gain from installing a second copy.
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openpitkit/pit
  REF "v0.8.0"
  SHA512 7c0b5eeb6ed1964076d93c15c0ffe747a3d41acb23dd41b49b7fcb203e903880b73f3cfb28e5b408b1a79265f1c9ab06c17e4b69f67aead4a4578bd3342f5ed7
  HEAD_REF main)

# Select the engine for the target triplet and supply it to both the package
# build and the exported config. All downloads stay in the vcpkg asset cache.
if(VCPKG_TARGET_IS_WINDOWS)
  if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR
      "openpit: no prebuilt engine for windows-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
  set(openpit_runtime_asset "openpit-ffi--windows-amd64-openpit_ffi.dll")
  set(openpit_runtime_sha512 "5907fb719c23fff6fc23d27c277d64659ee274ab32e1b9fbb28b8cab797f159341a4cbde456eb8c69ac64f7abbad144783ad7cc03172e657b631b34f5e76931c")
  set(openpit_runtime_file "openpit_ffi.dll")
  set(openpit_implib_asset "openpit-ffi--windows-amd64-openpit_ffi.dll.lib")
  set(openpit_implib_sha512 "1eb93db664806cd90ec7c636219773bd13c0bacbbd8e35b92b47e25b5fbd324462826e7ed9873b3d5e0362515355578b24d6321dec5cb92324eea891f49e4d60")
  set(openpit_implib_file "openpit_ffi.lib")
elseif(VCPKG_TARGET_IS_OSX)
  set(openpit_runtime_file "libopenpit_ffi.dylib")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--darwin-arm64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "7f0b61237178a682ae213b47d4073ba1fc5d05a2c479db255403ade170328ef29710d7ad0c78aea18d79a223d45700abf88e7fada488087b366093525ba2ba8d")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--darwin-amd64-libopenpit_ffi.dylib")
    set(openpit_runtime_sha512 "10095d7d3f2d7db1b6745f9877c899d00d11e0b86d871ac4257dba518cfa0548c3aa5c8d338664b7d7cf73c8d193f7f90a8219f82f774e4756181eb8dc4b9f90")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for osx-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  set(openpit_runtime_file "libopenpit_ffi.so")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(openpit_runtime_asset "openpit-ffi--linux-arm64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "27d7a6348b239dccf6ccf6d5d5b12f2200e03b994f761583dee0bc7e88f1ee52ef79d3830ee45417af40f05131b7abc6f898c708f621e60fae00ddac2724fb2b")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(openpit_runtime_asset "openpit-ffi--linux-amd64-libopenpit_ffi.so")
    set(openpit_runtime_sha512 "64e5848732879f143cf5408ec5b89d39222fbdc0aad51413e833e6eccdc309dede68914e77c532cb50a811b872ba5e058751217623799434650b8999eb4d106b")
  else()
    message(FATAL_ERROR
      "openpit: no prebuilt engine for linux-${VCPKG_TARGET_ARCHITECTURE}")
  endif()
else()
  message(FATAL_ERROR "openpit: unsupported target platform")
endif()

vcpkg_download_distfile(openpit_runtime_path
  URLS "https://github.com/openpitkit/pit/releases/download/v0.8.0/${openpit_runtime_asset}"
  FILENAME "${openpit_runtime_asset}"
  SHA512 "${openpit_runtime_sha512}")

set(openpit_runtime_options
  "-DOPENPIT_RUNTIME_LIBRARY=${openpit_runtime_path}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_download_distfile(openpit_implib_path
    URLS "https://github.com/openpitkit/pit/releases/download/v0.8.0/${openpit_implib_asset}"
    FILENAME "${openpit_implib_asset}"
    SHA512 "${openpit_implib_sha512}")
  list(APPEND openpit_runtime_options
    "-DOPENPIT_RUNTIME_IMPORT_LIBRARY=${openpit_implib_path}")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}/bindings/cpp"
  OPTIONS
    ${openpit_runtime_options}
    "-DOPENPIT_CPP_BUILD_TESTS=OFF"
    "-DOPENPIT_PACKAGE_VERSION=0.8.0"
    "-DOPENPIT_RUNTIME_VERSION=0.8.0")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenPit)

if(VCPKG_TARGET_IS_WINDOWS)
  file(INSTALL "${openpit_runtime_path}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
    RENAME "${openpit_runtime_file}")
  file(INSTALL "${openpit_implib_path}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    RENAME "${openpit_implib_file}")
  set(openpit_runtime_dir "bin")
else()
  file(INSTALL "${openpit_runtime_path}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    RENAME "${openpit_runtime_file}")
  set(openpit_runtime_dir "lib")
endif()

# Point the exported config at the engine this port just installed. The
# resolver returns on the first branch when the path is set, so a consumer
# never reaches for a release asset. The config lives in share/${PORT}, hence
# two levels up.
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
vcpkg_replace_string(
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenPitConfig.cmake"
  "openpit_resolve_runtime()"
  "${openpit_config_runtime}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
