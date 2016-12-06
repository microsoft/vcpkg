# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
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

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openssl-OpenSSL_1_0_2_WinRT-stable)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "${PERL_EXE_PATH};$ENV{PATH}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/openssl/archive/OpenSSL_1_0_2_WinRT-stable.zip"
    FILENAME "openssl-microsoft-1.0.2.zip"
    SHA512 10c3d7eb354a0b39a837e0c48f31415444acd5b1e7df52ed49a735ea63bf8b7548602a266baa012f1703888e68fdd5cb070fc610584a2f3f9a555e7d62d8b44b
)

vcpkg_extract_source_archive(${ARCHIVE})

file(REMOVE_RECURSE ${SOURCE_PATH}/tmp32dll)
file(REMOVE_RECURSE ${SOURCE_PATH}/out32dll)
file(REMOVE_RECURSE ${SOURCE_PATH}/inc32dll)

file(COPY
${CMAKE_CURRENT_LIST_DIR}/setVSvars.bat
DESTINATION ${SOURCE_PATH}/ms)

file(COPY
${CMAKE_CURRENT_LIST_DIR}/make-openssl.bat
DESTINATION ${SOURCE_PATH})

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

file(INSTALL ${SOURCE_PATH}/out32dll/libeay32.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(INSTALL ${SOURCE_PATH}/out32dll/libeay32.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(INSTALL ${SOURCE_PATH}/out32dll/libeay32.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/out32dll/ssleay32.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(INSTALL ${SOURCE_PATH}/out32dll/ssleay32.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(INSTALL ${SOURCE_PATH}/out32dll/ssleay32.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)



file(INSTALL ${SOURCE_PATH}/out32dll/libeay32.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/out32dll/libeay32.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/out32dll/libeay32.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(INSTALL ${SOURCE_PATH}/out32dll/ssleay32.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/out32dll/ssleay32.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/out32dll/ssleay32.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)



file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openssl RENAME copyright)
