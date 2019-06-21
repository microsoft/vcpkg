include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "This port is only for building openssl on Windows Desktop")
endif()

if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
  message(WARNING "Can't build openssl if libressl is installed. Please remove libressl, and try install openssl again if you need it. Build will continue but there might be problems since libressl is only a subset of openssl")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  return()
endif()

set(OPENSSL_VERSION 1.0.2q)

vcpkg_find_acquire_program(PERL)

get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" "https://www.openssl.org/source/old/1.0.2/openssl-${OPENSSL_VERSION}.tar.gz"
    FILENAME "openssl-${OPENSSL_VERSION}.tar.gz"
    SHA512 403e6cad42db3ba860c3fa4fa81c1b7b02f0b873259e5c19a7fc8e42de0854602555f1b1ca74f4e3a7737a4cbd3aac063061e628ec86534586500819fae7fec0
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  PATCHES
    ConfigureIncludeQuotesFix.patch
    STRINGIFYPatch.patch
    EnableWinARM32.patch
    EmbedSymbolsInStaticLibsZ7.patch
    EnableWinARM64.patch
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
set(ENV{PATH} "${NASM_EXE_PATH};$ENV{PATH}")

vcpkg_find_acquire_program(JOM)

set(CONFIGURE_COMMAND ${PERL} Configure
    enable-static-engine
    enable-capieng
    no-ssl2
    -utf-8
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(OPENSSL_ARCH VC-WIN32)
    set(OPENSSL_DO "ms\\do_nasm.bat")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(OPENSSL_ARCH VC-WIN64A)
    set(OPENSSL_DO "ms\\do_win64a.bat")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(OPENSSL_ARCH VC-WIN32)
    set(OPENSSL_DO "ms\\do_ms.bat")
    set(CONFIGURE_COMMAND ${CONFIGURE_COMMAND}
        no-asm
        -D_ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE
    )
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(OPENSSL_ARCH VC-WIN32)
    set(OPENSSL_DO "ms\\do_ms.bat")
    set(CONFIGURE_COMMAND ${CONFIGURE_COMMAND}
        no-asm
        -D_ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE
    )
else()
    message(FATAL_ERROR "Unsupported target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPENSSL_MAKEFILE "ms\\ntdll.mak")
else()
    set(OPENSSL_MAKEFILE "ms\\nt.mak")
endif()

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)


if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")

    # Copy openssl sources.
    message(STATUS "Copying openssl release source files...")
    file(GLOB OPENSSL_SOURCE_FILES ${SOURCE_PATH}/*)
    foreach(SOURCE_FILE ${OPENSSL_SOURCE_FILES})
        file(COPY ${SOURCE_FILE} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    endforeach()
    message(STATUS "Copying openssl release source files... done")
    set(SOURCE_PATH_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

    set(OPENSSLDIR_RELEASE ${CURRENT_PACKAGES_DIR})

    message(STATUS "Configure ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${CONFIGURE_COMMAND} ${OPENSSL_ARCH} "--prefix=${OPENSSLDIR_RELEASE}" "--openssldir=${OPENSSLDIR_RELEASE}" -FS
        WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
        LOGNAME configure-perl-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}-rel
    )
    vcpkg_execute_required_process(
        COMMAND ${OPENSSL_DO}
        WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
        LOGNAME configure-do-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}-rel
    )
    message(STATUS "Configure ${TARGET_TRIPLET}-rel done")

    message(STATUS "Build ${TARGET_TRIPLET}-rel")
    # Openssl's buildsystem has a race condition which will cause JOM to fail at some point.
    # This is ok; we just do as much work as we can in parallel first, then follow up with a single-threaded build.
    make_directory(${SOURCE_PATH_RELEASE}/inc32/openssl)
    execute_process(
        COMMAND ${JOM} -k -j $ENV{NUMBER_OF_PROCESSORS} -f ${OPENSSL_MAKEFILE}
        WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
        OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-rel-0-out.log
        ERROR_FILE ${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-rel-0-err.log
    )
    vcpkg_execute_required_process(
        COMMAND nmake -f ${OPENSSL_MAKEFILE} install
        WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
        LOGNAME build-${TARGET_TRIPLET}-rel-1)

    message(STATUS "Build ${TARGET_TRIPLET}-rel done")
endif()


if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    # Copy openssl sources.
    message(STATUS "Copying openssl debug source files...")
    file(GLOB OPENSSL_SOURCE_FILES ${SOURCE_PATH}/*)
    foreach(SOURCE_FILE ${OPENSSL_SOURCE_FILES})
        file(COPY ${SOURCE_FILE} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    endforeach()
    message(STATUS "Copying openssl debug source files... done")
    set(SOURCE_PATH_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    set(OPENSSLDIR_DEBUG ${CURRENT_PACKAGES_DIR}/debug)

    message(STATUS "Configure ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${CONFIGURE_COMMAND} debug-${OPENSSL_ARCH} "--prefix=${OPENSSLDIR_DEBUG}" "--openssldir=${OPENSSLDIR_DEBUG}" -FS
        WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
        LOGNAME configure-perl-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}-dbg
    )
    vcpkg_execute_required_process(
        COMMAND ${OPENSSL_DO}
        WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
        LOGNAME configure-do-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}-dbg
    )
    message(STATUS "Configure ${TARGET_TRIPLET}-dbg done")

    message(STATUS "Build ${TARGET_TRIPLET}-dbg")
    make_directory(${SOURCE_PATH_DEBUG}/inc32/openssl)
    execute_process(
        COMMAND ${JOM} -k -j $ENV{NUMBER_OF_PROCESSORS} -f ${OPENSSL_MAKEFILE}
        WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
        OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-dbg-0-out.log
        ERROR_FILE ${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-dbg-0-err.log
    )
    vcpkg_execute_required_process(
        COMMAND nmake -f ${OPENSSL_MAKEFILE} install
        WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
        LOGNAME build-${TARGET_TRIPLET}-dbg-1)

    message(STATUS "Build ${TARGET_TRIPLET}-dbg done")
endif()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/bin/openssl.exe
    ${CURRENT_PACKAGES_DIR}/debug/openssl.cnf
    ${CURRENT_PACKAGES_DIR}/openssl.cnf
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/openssl/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/openssl.exe ${CURRENT_PACKAGES_DIR}/tools/openssl/openssl.exe)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openssl)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # They should be empty, only the exes deleted above were in these directories
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)
endif()

file(READ "${CURRENT_PACKAGES_DIR}/include/openssl/dtls1.h" _contents)
string(REPLACE "<winsock.h>" "<winsock2.h>" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/openssl/dtls1.h" "${_contents}")

file(READ "${CURRENT_PACKAGES_DIR}/include/openssl/rand.h" _contents)
string(REPLACE "#  include <windows.h>" "#ifndef _WINSOCKAPI_\n#define _WINSOCKAPI_\n#endif\n#  include <windows.h>" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/openssl/rand.h" "${_contents}")

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME OpenSSL MODULE)
