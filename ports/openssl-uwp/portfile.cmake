if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(VCPKG_LIBRARY_LINKAGE dynamic)
    message("Static building not supported yet")
endif()

if (NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "This portfile only supports UWP")
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(UWP_PLATFORM  "arm")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(UWP_PLATFORM  "x64")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(UWP_PLATFORM  "Win32")
else ()
    message(FATAL_ERROR "Unsupported architecture")
endif()

include(vcpkg_common_functions)


vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(JOM)
get_filename_component(JOM_EXE_PATH ${JOM} DIRECTORY)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH};${JOM_EXE_PATH}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/openssl/archive/OpenSSL_1_0_2q_WinRT.zip"
    FILENAME "openssl-microsoft-1.0.2q_WinRT.zip"
    SHA512 828ddeb10b7d04155df64cb38f3d8b8109ff01494fed7f6c1063673e45414c1c309379e8bbe72478bd0fbae649d6749877c20b1b4a91db136a0853745f4da6b6
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
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
