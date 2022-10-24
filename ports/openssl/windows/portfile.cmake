vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH "${NASM}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${NASM_EXE_PATH}")

vcpkg_find_acquire_program(JOM)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(OPENSSL_SHARED shared)
else()
    set(OPENSSL_SHARED no-shared no-module)
endif()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

set(ENV{CC} "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
set(ENV{CXX} "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
set(ENV{AR} "${VCPKG_DETECTED_CMAKE_AR}")
set(ENV{LD} "${VCPKG_DETECTED_CMAKE_LINKER}")

set(CONFIGURE_OPTIONS
    enable-static-engine
    enable-capieng
    no-ssl2
    no-tests
    ${OPENSSL_SHARED}
)

if(DEFINED OPENSSL_USE_NOPINSHARED)
    set(CONFIGURE_OPTIONS ${CONFIGURE_OPTIONS} no-pinshared)
endif()

if(OPENSSL_NO_AUTOLOAD_CONFIG)
    set(CONFIGURE_OPTIONS ${CONFIGURE_OPTIONS} no-autoload-config)
endif()

set(CONFIGURE_COMMAND "${PERL}" Configure ${CONFIGURE_OPTIONS})

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(OPENSSL_ARCH VC-WIN32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(OPENSSL_ARCH VC-WIN64A)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(OPENSSL_ARCH VC-WIN32-ARM)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(OPENSSL_ARCH VC-WIN64-ARM)
else()
    message(FATAL_ERROR "Unsupported target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(OPENSSL_MAKEFILE "makefile")

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
                    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

# Clang always uses /Z7;  Patching /Zi /Fd<Name> out of openssl requires more work.
if (VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES "Clang" OR VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OPENSSL_BUILD_MAKES_PDBS OFF)
else()
    set(OPENSSL_BUILD_MAKES_PDBS ON)
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    # Copy openssl sources.
    message(STATUS "Copying openssl release source files...")
    file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

    message(STATUS "Copying openssl release source files... done")
    set(SOURCE_PATH_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

    set(OPENSSLDIR_RELEASE "${CURRENT_PACKAGES_DIR}")

    # Remove install rules for pdbs if they don't exist
    if(NOT OPENSSL_BUILD_MAKES_PDBS)
        file(READ "${SOURCE_PATH_RELEASE}/Configurations/windows-makefile.tmpl" contents)
        string(REGEX REPLACE [["\$\(PERL\)" "\$\(SRCDIR\)\\util\\copy.pl" \$\(INSTALL_(ENGINE|MODULE|SHLIB|PROGRAM)PDBS\)]] "echo " contents "${contents}")
        string(REGEX REPLACE [["\$\(PERL\)" "\$\(SRCDIR\)\\util\\copy.pl" ossl_static.pdb]] "echo " contents "${contents}")
        file(WRITE "${SOURCE_PATH_RELEASE}/Configurations/windows-makefile.tmpl" "${contents}")
    endif()

    set(ENV{CFLAGS} "${VCPKG_COMBINED_C_FLAGS_RELEASE}")
    set(ENV{CXXFLAGS} "${VCPKG_COMBINED_CXX_FLAGS_RELEASE}")
    set(ENV{LDFLAGS} "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_RELEASE}")
    set(ENV{ARFLAGS} "${VCPKG_COMBINED_STATIC_LINKER_FLAGS_RELEASE}")

    message(STATUS "Configure ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${CONFIGURE_COMMAND} ${OPENSSL_ARCH} "--prefix=${OPENSSLDIR_RELEASE}" "--openssldir=${OPENSSLDIR_RELEASE}" -FS
        WORKING_DIRECTORY "${SOURCE_PATH_RELEASE}"
        LOGNAME configure-perl-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Configure ${TARGET_TRIPLET}-rel done")

    message(STATUS "Build ${TARGET_TRIPLET}-rel")
    # Openssl's buildsystem has a race condition which will cause JOM to fail at some point.
    # This is ok; we just do as much work as we can in parallel first, then follow up with a single-threaded build.
    make_directory("${SOURCE_PATH_RELEASE}/inc32/openssl")
    execute_process(
        COMMAND "${JOM}" -k -j "${VCPKG_CONCURRENCY}" -f "${OPENSSL_MAKEFILE}"
        WORKING_DIRECTORY "${SOURCE_PATH_RELEASE}"
        OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-rel-0-out.log"
        ERROR_FILE "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-rel-0-err.log"
    )
    vcpkg_execute_required_process(
        COMMAND "${JOM}" -j 1 -f "${OPENSSL_MAKEFILE}" install_sw install_ssldirs
        WORKING_DIRECTORY "${SOURCE_PATH_RELEASE}"
        LOGNAME build-${TARGET_TRIPLET}-rel-1)

    message(STATUS "Build ${TARGET_TRIPLET}-rel done")
endif()


if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    # Copy openssl sources.
    message(STATUS "Copying openssl debug source files...")
    file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    message(STATUS "Copying openssl debug source files... done")
    set(SOURCE_PATH_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    # Remove install rules for pdbs if they don't exist
    if(NOT OPENSSL_BUILD_MAKES_PDBS)
        file(READ "${SOURCE_PATH_DEBUG}/Configurations/windows-makefile.tmpl" contents)
        string(REGEX REPLACE [["\$\(PERL\)" "\$\(SRCDIR\)\\util\\copy.pl" \$\(INSTALL_(ENGINE|MODULE|SHLIB|PROGRAM)PDBS\)]] "echo " contents "${contents}")
        string(REGEX REPLACE [["\$\(PERL\)" "\$\(SRCDIR\)\\util\\copy.pl" ossl_static.pdb]] "echo " contents "${contents}")
        file(WRITE "${SOURCE_PATH_DEBUG}/Configurations/windows-makefile.tmpl" "${contents}")
    endif()

    set(OPENSSLDIR_DEBUG "${CURRENT_PACKAGES_DIR}/debug")

    set(ENV{CFLAGS} "${VCPKG_COMBINED_C_FLAGS_DEBUG}")
    set(ENV{CXXFLAGS} "${VCPKG_COMBINED_CXX_FLAGS_DEBUG}")
    set(ENV{LDFLAGS} "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_DEBUG}")
    set(ENV{ARFLAGS} "${VCPKG_COMBINED_STATIC_LINKER_FLAGS_DEBUG}")

    message(STATUS "Configure ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${CONFIGURE_COMMAND} debug-${OPENSSL_ARCH} "--prefix=${OPENSSLDIR_DEBUG}" "--openssldir=${OPENSSLDIR_DEBUG}" -FS
        WORKING_DIRECTORY "${SOURCE_PATH_DEBUG}"
        LOGNAME configure-perl-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Configure ${TARGET_TRIPLET}-dbg done")

    message(STATUS "Build ${TARGET_TRIPLET}-dbg")
    make_directory("${SOURCE_PATH_DEBUG}/inc32/openssl")
    execute_process(
        COMMAND "${JOM}" -k -j "${VCPKG_CONCURRENCY}" -f "${OPENSSL_MAKEFILE}"
        WORKING_DIRECTORY "${SOURCE_PATH_DEBUG}"
        OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-dbg-0-out.log"
        ERROR_FILE "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-dbg-0-err.log"
    )
    vcpkg_execute_required_process(
        COMMAND "${JOM}" -j 1 -f "${OPENSSL_MAKEFILE}" install_sw install_ssldirs
        WORKING_DIRECTORY "${SOURCE_PATH_DEBUG}"
        LOGNAME build-${TARGET_TRIPLET}-dbg-1)

        message(STATUS "Build ${TARGET_TRIPLET}-dbg done")

        if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND NOT VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES "Clang")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/ossl-modules/legacy.pdb" "${CURRENT_PACKAGES_DIR}/debug/bin/legacy.pdb")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/ossl-modules/legacy.pdb" "${CURRENT_PACKAGES_DIR}/bin/legacy.pdb")
        endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/certs")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/private")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/engines-1_1")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/engines-3")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/certs")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/engines-1_1")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/engines-3")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/private")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(NOT VCPKG_BUILD_TYPE)
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/ossl-modules/legacy.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/legacy.dll")
    endif()
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/ossl-modules/legacy.dll" "${CURRENT_PACKAGES_DIR}/bin/legacy.dll")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/ossl-modules")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/ossl-modules")

file(REMOVE
    "${CURRENT_PACKAGES_DIR}/ct_log_list.cnf"
    "${CURRENT_PACKAGES_DIR}/ct_log_list.cnf.dist"
    "${CURRENT_PACKAGES_DIR}/openssl.cnf.dist"
    "${CURRENT_PACKAGES_DIR}/debug/bin/openssl.exe"
    "${CURRENT_PACKAGES_DIR}/debug/ct_log_list.cnf"
    "${CURRENT_PACKAGES_DIR}/debug/ct_log_list.cnf.dist"
    "${CURRENT_PACKAGES_DIR}/debug/openssl.cnf"
    "${CURRENT_PACKAGES_DIR}/debug/openssl.cnf.dist"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/openssl/")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/openssl.exe" "${CURRENT_PACKAGES_DIR}/tools/openssl/openssl.exe")
file(RENAME "${CURRENT_PACKAGES_DIR}/openssl.cnf" "${CURRENT_PACKAGES_DIR}/tools/openssl/openssl.cnf")

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/openssl")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # They should be empty, only the exes deleted above were in these directories
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/openssl/dtls1.h"
    "<winsock.h>"
    "<winsock2.h>"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/openssl/rand.h"
    "#  include <windows.h>"
    "#ifndef _WINSOCKAPI_\n#define _WINSOCKAPI_\n#endif\n#  include <windows.h>"
)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
