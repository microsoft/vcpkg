if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    include(${CMAKE_CURRENT_LIST_DIR}/portfile-uwp.cmake)
    return()
endif()

include(vcpkg_common_functions)
set(OPENSSL_VERSION 1.0.2l)
set(MASTER_COPY_SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openssl-${OPENSSL_VERSION})

vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(NASM)
find_program(NMAKE nmake)

get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_find_acquire_program(JOM)
set(ENV{PATH} "${NASM_EXE_PATH};$ENV{PATH};${PERL_EXE_PATH}")

vcpkg_download_distfile(OPENSSL_SOURCE_ARCHIVE
    URLS "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" "https://www.openssl.org/source/old/1.0.2/openssl-${OPENSSL_VERSION}.tar.gz"
    FILENAME "openssl-${OPENSSL_VERSION}.tar.gz"
    SHA512 047d964508ad6025c79caabd8965efd2416dc026a56183d0ef4de7a0a6769ce8e0b4608a3f8393d326f6d03b26a2b067e6e0c750f35b20be190e595e8290c0e3
)

vcpkg_extract_source_archive(${OPENSSL_SOURCE_ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${MASTER_COPY_SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/PerlScriptSpaceInPathFixes.patch
            ${CMAKE_CURRENT_LIST_DIR}/ConfigureIncludeQuotesFix.patch
            ${CMAKE_CURRENT_LIST_DIR}/STRINGIFYPatch.patch
            ${CMAKE_CURRENT_LIST_DIR}/EmbedSymbolsInStaticLibsZ7.patch
)

set(CONFIGURE_COMMAND ${PERL} Configure
    enable-static-engine
    enable-capieng
    no-ssl2
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(OPENSSL_ARCH VC-WIN32)
    set(OPENSSL_DO "ms\\do_nasm.bat")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(OPENSSL_ARCH VC-WIN64A)
    set(OPENSSL_DO "ms\\do_win64a.bat")
else()
    message(FATAL_ERROR "Unsupported target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPENSSL_MAKEFILE "ms\\ntdll.mak")
else()
    set(OPENSSL_MAKEFILE "ms\\nt.mak")
endif()

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)


file(COPY ${MASTER_COPY_SOURCE_PATH} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/openssl-${OPENSSL_VERSION})
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
    COMMAND ${NMAKE} -f ${OPENSSL_MAKEFILE} install
    WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
    LOGNAME build-${TARGET_TRIPLET}-rel-1)

message(STATUS "Build ${TARGET_TRIPLET}-rel done")


message(STATUS "Configure ${TARGET_TRIPLET}-dbg")
file(COPY ${MASTER_COPY_SOURCE_PATH} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
set(SOURCE_PATH_DEBUG ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/openssl-${OPENSSL_VERSION})
set(OPENSSLDIR_DEBUG ${CURRENT_PACKAGES_DIR}/debug)

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
    COMMAND ${NMAKE} -f ${OPENSSL_MAKEFILE} install
    WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
    LOGNAME build-${TARGET_TRIPLET}-dbg-1)

message(STATUS "Build ${TARGET_TRIPLET}-dbg done")


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/bin/openssl.exe
    ${CURRENT_PACKAGES_DIR}/debug/openssl.cnf
    ${CURRENT_PACKAGES_DIR}/openssl.cnf
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/openssl.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/openssl.exe)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openssl RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # They should be empty, only the exes deleted above were in these directories
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)
endif()

vcpkg_copy_pdbs()
