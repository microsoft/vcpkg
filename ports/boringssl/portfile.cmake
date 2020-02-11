vcpkg_fail_port_install(ON_TARGET "UWP")

if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
  message(WARNING "Can't build BoringSSL if OpenSSL is installed. Please remove OpenSSL, and try to install BoringSSL again if you need it. Build will continue since BoringSSL is a drop-in replacement for OpenSSL")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  return()
endif()

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_EXE_PATH})

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path(${NASM_EXE_PATH})

vcpkg_find_acquire_program(GO)
get_filename_component(GO_EXE_PATH ${GO} DIRECTORY)
vcpkg_add_to_path(${GO_EXE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  tools INSTALL_TOOLS
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/boringssl
  REF 7e43e2e8eecc9114f829e6d75cc3c04d1af57504
  SHA512 b49acc36d878730c29376f1bdd8b8d1c4ebfb7bcc6110e11401b479c36da62e93939a0702624d3d9ca0f40240346f0d30c6a7e48cc43084395fde8d8683ac5eb
  HEAD_REF master
  PATCHES
    0001-vcpkg.patch
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    ${FEATURE_OPTIONS}
  OPTIONS_DEBUG
    -DINSTALL_HEADERS=OFF
    -DINSTALL_TOOLS=OFF
)

vcpkg_install_cmake()

if(IS_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/boringssl)
  vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/boringssl")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
