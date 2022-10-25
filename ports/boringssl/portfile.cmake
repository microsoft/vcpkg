if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
  message(FATAL_ERROR "Can't build BoringSSL if OpenSSL is installed. Please remove OpenSSL, and try to install BoringSSL again if you need it. Build will continue since BoringSSL is a drop-in replacement for OpenSSL")
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
    FEATURES
        tools INSTALL_TOOLS
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/boringssl
  REF 479adf98d54a21c1d154aac59b2ce120e1d1a6d6
  SHA512 74b5d001c0f5c1846b8818e9e668fa35de5171fc21a8f713d241f57b3e8abe42426fdc66b085cca1853b904def6f4bea573dfed40b8b1422894cca85b0b1a44a
  HEAD_REF master
  PATCHES
    0001-vcpkg.patch
    0002-remove-WX-Werror.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${FEATURE_OPTIONS}
  OPTIONS_DEBUG
    -DINSTALL_HEADERS=OFF
    -DINSTALL_TOOLS=OFF
)

vcpkg_cmake_install()

include("${CMAKE_CURRENT_LIST_DIR}/install-pc-files.cmake")

if(IS_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/boringssl)
  vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/boringssl")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
