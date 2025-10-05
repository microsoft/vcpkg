# Need cmd to pass quoted CC from nmake to mkbuildinf.pl, GH-37134
find_program(CMD_EXECUTABLE cmd HINTS ENV PATH NO_DEFAULT_PATH REQUIRED)
cmake_path(NATIVE_PATH CMD_EXECUTABLE cmd)
set(ENV{COMSPEC} "${cmd}")

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH "${PERL}" DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(OPENSSL_ARCH VC-WIN32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(OPENSSL_ARCH VC-WIN64A)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(OPENSSL_ARCH VC-WIN32-ARM)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    if(VCPKG_TARGET_IS_UWP)
        set(OPENSSL_ARCH VC-WIN64-ARM)
    elseif(VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES "Clang")
        set(OPENSSL_ARCH VC-CLANG-WIN64-CLANGASM-ARM)
    else()
        set(OPENSSL_ARCH VC-WIN64-CLANGASM-ARM)
    endif()
else()
    message(FATAL_ERROR "Unsupported target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if(VCPKG_TARGET_IS_UWP)
    vcpkg_list(APPEND CONFIGURE_OPTIONS
        no-unit-test
        no-asm
        no-uplink
    )
    string(APPEND OPENSSL_ARCH "-UWP")
endif()

if(VCPKG_CONCURRENCY GREATER "1")
    vcpkg_list(APPEND CONFIGURE_OPTIONS no-makedepend)
endif()

cmake_path(NATIVE_PATH CURRENT_PACKAGES_DIR NORMALIZE install_dir_native)

# Clang always uses /Z7;  Patching /Zi /Fd<Name> out of openssl requires more work.
set(OPENSSL_BUILD_MAKES_PDBS ON)
if (VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES "Clang" OR VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(OPENSSL_BUILD_MAKES_PDBS OFF)
endif()

cmake_path(NATIVE_PATH VCPKG_DETECTED_CMAKE_C_COMPILER NORMALIZE cc)
if(OPENSSL_ARCH MATCHES "CLANG")
    vcpkg_find_acquire_program(CLANG)
    cmake_path(GET CLANG PARENT_PATH clang_path)
    vcpkg_add_to_path("${clang_path}")
    if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES "Clang")
        string(APPEND VCPKG_COMBINED_C_FLAGS_DEBUG " --target=aarch64-win32-msvc")
        string(APPEND VCPKG_COMBINED_C_FLAGS_RELEASE " --target=aarch64-win32-msvc")
    endif()
endif()
if(OPENSSL_ARCH MATCHES "CLANGASM")
    vcpkg_list(APPEND CONFIGURE_OPTIONS "ASFLAGS=--target=aarch64-win32-msvc")
else()
    vcpkg_find_acquire_program(NASM)
    cmake_path(NATIVE_PATH NASM NORMALIZE as)
    cmake_path(GET NASM PARENT_PATH nasm_path)
    vcpkg_add_to_path("${nasm_path}") # Needed by Configure
endif()

cmake_path(NATIVE_PATH VCPKG_DETECTED_CMAKE_AR NORMALIZE ar)
cmake_path(NATIVE_PATH VCPKG_DETECTED_CMAKE_LINKER NORMALIZE ld)

vcpkg_build_nmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_JOM
    CL_LANGUAGE NONE
    PRERUN_SHELL_RELEASE "${PERL}" Configure
        ${CONFIGURE_OPTIONS} 
        ${OPENSSL_ARCH}
        "--prefix=${install_dir_native}"
        "--openssldir=${install_dir_native}"
        "AS=${as}"
        "CC=${cc}"
        "CFLAGS=${VCPKG_COMBINED_C_FLAGS_RELEASE}"
        "AR=${ar}"
        "ARFLAGS=${VCPKG_COMBINED_STATIC_LINKER_FLAGS_RELEASE}"
        "LD=${ld}"
        "LDFLAGS=${VCPKG_COMBINED_SHARED_LINKER_FLAGS_RELEASE}"
    PRERUN_SHELL_DEBUG "${PERL}" Configure
        ${CONFIGURE_OPTIONS}
        ${OPENSSL_ARCH}
        --debug
        "--prefix=${install_dir_native}\\debug"
        "--openssldir=${install_dir_native}\\debug"
        "AS=${as}"
        "CC=${cc}"
        "CFLAGS=${VCPKG_COMBINED_C_FLAGS_DEBUG}"
        "AR=${ar}"
        "ARFLAGS=${VCPKG_COMBINED_STATIC_LINKER_FLAGS_DEBUG}"
        "LD=${ld}"
        "LDFLAGS=${VCPKG_COMBINED_SHARED_LINKER_FLAGS_DEBUG}"
    PROJECT_NAME "makefile"
    TARGET install_dev install_modules ${INSTALL_FIPS}
    LOGFILE_ROOT install
    OPTIONS
        "INSTALL_PDBS=${OPENSSL_BUILD_MAKES_PDBS}" # install-pdbs.patch
    OPTIONS_RELEASE
        install_runtime install_ssldirs # extra targets
)

set(scripts "bin/c_rehash.pl" "misc/CA.pl" "misc/tsget.pl")
if("tools" IN_LIST FEATURES)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/openssl.cnf" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/openssl.cnf")
    if("fips" IN_LIST FEATURES)
	file(RENAME "${CURRENT_PACKAGES_DIR}/fipsmodule.cnf" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/fipsmodule.cnf")
    endif()
    foreach(script IN LISTS scripts)
        file(COPY "${CURRENT_PACKAGES_DIR}/${script}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/${script}" "${CURRENT_PACKAGES_DIR}/debug/${script}")
    endforeach()
    vcpkg_copy_tools(TOOL_NAMES openssl AUTO_CLEAN)
else()
    file(REMOVE "${CURRENT_PACKAGES_DIR}/openssl.cnf")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/fipsmodule.cnf")
    foreach(script IN LISTS scripts)
        file(REMOVE "${CURRENT_PACKAGES_DIR}/${script}" "${CURRENT_PACKAGES_DIR}/debug/${script}")
    endforeach()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/certs"
    "${CURRENT_PACKAGES_DIR}/misc"
    "${CURRENT_PACKAGES_DIR}/private"
    "${CURRENT_PACKAGES_DIR}/lib/engines-3"
    "${CURRENT_PACKAGES_DIR}/debug/certs"
    "${CURRENT_PACKAGES_DIR}/debug/misc"
    "${CURRENT_PACKAGES_DIR}/debug/lib/engines-3"
    "${CURRENT_PACKAGES_DIR}/debug/private"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
file(REMOVE
    "${CURRENT_PACKAGES_DIR}/ct_log_list.cnf"
    "${CURRENT_PACKAGES_DIR}/ct_log_list.cnf.dist"
    "${CURRENT_PACKAGES_DIR}/openssl.cnf.dist"
    "${CURRENT_PACKAGES_DIR}/debug/ct_log_list.cnf"
    "${CURRENT_PACKAGES_DIR}/debug/ct_log_list.cnf.dist"
    "${CURRENT_PACKAGES_DIR}/debug/openssl.cnf"
    "${CURRENT_PACKAGES_DIR}/debug/openssl.cnf.dist"
    "${CURRENT_PACKAGES_DIR}/debug/fipsmodule.cnf"
)
