if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
  message(FATAL_ERROR "Can't build BoringSSL if OpenSSL is installed. Please remove OpenSSL, and try to install BoringSSL again if you need it. Build will continue since BoringSSL is a drop-in replacement for OpenSSL")
endif()

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH "${PERL}" DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH "${NASM}" DIRECTORY)
vcpkg_add_to_path("${NASM_EXE_PATH}")

vcpkg_find_acquire_program(GO)
get_filename_component(GO_EXE_PATH "${GO}" DIRECTORY)
vcpkg_add_to_path("${GO_EXE_PATH}")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/boringssl
  REF 0.20250818.0
  SHA512 49404ac5a5fd0fd4254f24b586e5d6ae139df48b9163f865a1a16a7e6c27b9a9373863ffc89b5b3be20bbe01cce788cc146c887692be332ae4f522482862ccac
  HEAD_REF master
  PATCHES
    0001-static-gtest.patch
    0002-remove-WX-Werror.patch
    0003-fix-shared-symbol-visibility.patch
)

set(BORINGSSL_OPTIONS)
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  # MSVC armasm64 expects MASM syntax; BoringSSL uses GNU asm on arm64, so force the C fallback.
  list(APPEND BORINGSSL_OPTIONS "-DOPENSSL_NO_ASM=ON")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  # the FindOpenSSL.cmake script differentiates debug and release binaries using this suffix.
  set(CMAKE_CONFIGURE_OPTIONS_DEBUG "-DCMAKE_DEBUG_POSTFIX=d")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${BORINGSSL_OPTIONS}
  OPTIONS_DEBUG
    ${CMAKE_CONFIGURE_OPTIONS_DEBUG}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME OpenSSL CONFIG_PATH lib/cmake/OpenSSL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_tools(TOOL_NAMES bssl AUTO_CLEAN)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/install-pc-files.cmake")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
