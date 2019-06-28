include(vcpkg_common_functions)

if (NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "This portfile only supports UWP")
endif()

if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
  message(WARNING "Can't build openssl if libressl is installed. Please remove libressl, and try install openssl again if you need it. Build will continue but there might be problems since libressl is only a subset of openssl")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  return()
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(UWP_PLATFORM  "arm")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(UWP_PLATFORM  "arm64")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(UWP_PLATFORM  "x64")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(UWP_PLATFORM  "Win32")
else ()
    message(FATAL_ERROR "Unsupported architecture")
endif()

vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(JOM)
get_filename_component(JOM_EXE_PATH ${JOM} DIRECTORY)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH};${JOM_EXE_PATH}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/openssl
    REF OpenSSL_1_0_2r_WinRT
    SHA512 3045693fca4b042b69675f6164d8cc82106582cf31081d65a0adbd528f04e77fa48b3761f3be7bdf8ab962a093b28fec0ae6d7da02058f2b049f79b784c39c2e
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-uwp-rs4.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-uwp-configure-unicode.patch
)

file(REMOVE_RECURSE ${SOURCE_PATH}/tmp32dll)
file(REMOVE_RECURSE ${SOURCE_PATH}/out32dll)
file(REMOVE_RECURSE ${SOURCE_PATH}/inc32dll)

file(
    COPY ${CMAKE_CURRENT_LIST_DIR}/make-openssl.bat
    DESTINATION ${SOURCE_PATH}
)

message(STATUS "Build ${TARGET_TRIPLET}")
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/make-openssl.bat ${UWP_PLATFORM}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME make-openssl-${TARGET_TRIPLET}
)
message(STATUS "Build ${TARGET_TRIPLET} done")

file(
    COPY ${SOURCE_PATH}/inc32/openssl
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL
    ${SOURCE_PATH}/out32dll/libeay32.dll
    ${SOURCE_PATH}/out32dll/libeay32.pdb
    ${SOURCE_PATH}/out32dll/ssleay32.dll
    ${SOURCE_PATH}/out32dll/ssleay32.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(INSTALL
    ${SOURCE_PATH}/out32dll/libeay32.lib
    ${SOURCE_PATH}/out32dll/ssleay32.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
    ${SOURCE_PATH}/out32dll/libeay32.dll
    ${SOURCE_PATH}/out32dll/libeay32.pdb
    ${SOURCE_PATH}/out32dll/ssleay32.dll
    ${SOURCE_PATH}/out32dll/ssleay32.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL
    ${SOURCE_PATH}/out32dll/libeay32.lib
    ${SOURCE_PATH}/out32dll/ssleay32.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

vcpkg_test_cmake(PACKAGE_NAME OpenSSL MODULE)
