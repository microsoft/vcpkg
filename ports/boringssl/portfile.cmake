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
  REF 5902657734e2a796a514731e0fd0e80081ae43dc
  SHA512 89458748ccf7e00e2e12a1026e7c41099298dfb6d0daaf885f52b98c84e833a4407e997dd3a5b92d56ede495ef431325a4b228c2d81598bde082141339b16684
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
