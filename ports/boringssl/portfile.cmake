if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(FATAL_ERROR "BoringSSL doesn't currently support UWP")
endif()

if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
  message(WARNING "Can't build BoringSSL if OpenSSL is installed. Please remove OpenSSL, and try to install BoringSSL again if you need it. Build will continue since BoringSSL is a drop-in replacement for OpenSSL")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  return()
endif()

include(vcpkg_common_functions)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH}")

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
set(ENV{PATH} "${NASM_EXE_PATH};$ENV{PATH}")

vcpkg_find_acquire_program(GO)
get_filename_component(GO_EXE_PATH ${GO} DIRECTORY)
set(ENV{PATH} "${GO_EXE_PATH};$ENV{PATH}")

set(INSTALL_TOOLS OFF)
if("tools" IN_LIST FEATURES)
  set(INSTALL_TOOLS ON)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/boringssl
  REF f10ea55e9139d444d277cd03da519a2076e975dc
  SHA512 adf4374af906cf086cb2922a6a4d967376d0f66770f5dec943e4720e85fcf12ae7a658c95b415f93550c73b7737eb55fe33b7e5c69a1ccd87bb3314a26e1ac0f
  HEAD_REF master
  PATCHES
    0001-vcpkg.patch
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DINSTALL_TOOLS=${INSTALL_TOOLS}
  OPTIONS_DEBUG
    -DINSTALL_TOOLS=OFF
)

vcpkg_install_cmake()

if(INSTALL_TOOLS)
  if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    set(EXECUTABLE_SUFFIX .exe)
  endif()
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/boringssl")
  file(RENAME "${CURRENT_PACKAGES_DIR}/bin/bssl${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/boringssl/bssl${EXECUTABLE_SUFFIX}")
  vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/boringssl")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/bin"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
  )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
