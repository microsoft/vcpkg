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
  REF cfcb954901e264edb9915e501de64a81732c5edd
  SHA512 6fc7fff24c85ed580fb362f788b216ef04ca16976656c68c75d3fd72c84e28ed39a3ab8fcb064b7c7061f93a4d37d5426e36d259e1714fa62d90b99659a3ddc2
  HEAD_REF master
  PATCHES
    0001-static-gtest.patch
    0002-remove-WX-Werror.patch
    0003-fix-shared-symbol-visibility.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
  # the FindOpenSSL.cmake script differentiates debug and release binaries using this suffix.
  set(CMAKE_CONFIGURE_OPTIONS_DEBUG "-DCMAKE_DEBUG_POSTFIX=d")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
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
