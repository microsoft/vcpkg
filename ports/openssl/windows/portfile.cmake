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

cmake_path(NATIVE_PATH CURRENT_PACKAGES_DIR NORMALIZE current_packages_dir_native)

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

# We can't set openssldir because that would leak build machine information into the built binaries,
# and introduce vulnerabilities where OpenSSL would search those locations at runtime, potentially
# unexpectedly loading code from there. For example CVE-2019-12572
#
# Put the built bits in subdirectories with DESTDIR then move them where they go after the fact
# instead.
vcpkg_build_nmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_JOM
    CL_LANGUAGE NONE
    PRERUN_SHELL_RELEASE "${PERL}" Configure
        ${CONFIGURE_OPTIONS} 
        ${OPENSSL_ARCH}
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
        "DESTDIR=${current_packages_dir_native}"
        install_runtime install_ssldirs # extra targets
    OPTIONS_DEBUG
        "DESTDIR=${current_packages_dir_native}/debug"
)

function(z_rearrange_openssl_dirs)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "OUT_PROGRAM_FILES_DIR;FLAVOR_PREFIX" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "z_rearrange_openssl_dirs was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    # The resulting directory will contain something like "Program Files" or "Program Files (x86)";
    # globbing here to be architecture agnostic
    set(prefix_packages_dir "${CURRENT_PACKAGES_DIR}${arg_FLAVOR_PREFIX}")
    file(GLOB flavor_programfiles_dir LIST_DIRECTORIES true "${prefix_packages_dir}/Program*")
    if(NOT flavor_programfiles_dir)
        message(FATAL_ERROR "${flavor_programfiles_dir}: error: couldn't find program files dir")
    endif()

    if(DEFINED arg_OUT_PROGRAM_FILES_DIR)
        set("${arg_OUT_PROGRAM_FILES_DIR}" "${flavor_programfiles_dir}" PARENT_SCOPE)
    endif()

    set(flavor_openssl_dir "${flavor_programfiles_dir}/OpenSSL")
    if(NOT EXISTS "${flavor_openssl_dir}")
        message(FATAL_ERROR "${flavor_openssl_dir}: should exist and be OpenSSLDir")
    endif()

    # ideally we would use RENAME rather than COPY and REMOVE_RECURSE but CMake doesn't have an out
    # of the box way to do that correctly merging directories
    file(GLOB flavor_openssl_dirs LIST_DIRECTORIES true "${flavor_openssl_dir}/*")
    file(COPY ${flavor_openssl_dirs} DESTINATION "${prefix_packages_dir}")
    file(REMOVE_RECURSE "${flavor_openssl_dir}")
endfunction()

z_rearrange_openssl_dirs(FLAVOR_PREFIX "" OUT_PROGRAM_FILES_DIR release_programfiles)
if(NOT VCPKG_BUILD_TYPE)
    z_rearrange_openssl_dirs(FLAVOR_PREFIX "/debug" OUT_PROGRAM_FILES_DIR debug_programfiles)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${debug_programfiles}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/c_rehash.pl")
endif()

set(scripts "bin/c_rehash.pl" "misc/CA.pl" "misc/tsget.pl")
if("tools" IN_LIST FEATURES)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(COPY_FILE "${release_programfiles}/Common Files/SSL/openssl.cnf" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/openssl.cnf")
    if("fips" IN_LIST FEATURES)
	    file(COPY_FILE "${release_programfiles}/Common Files/SSL/fipsmodule.cnf" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/fipsmodule.cnf")
    endif()

    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/c_rehash.pl" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/c_rehash.pl")
    file(RENAME "${release_programfiles}/Common Files/SSL/misc/CA.pl" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/CA.pl")
    file(RENAME "${release_programfiles}/Common Files/SSL/misc/tsget.pl" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/tsget.pl")
    vcpkg_copy_tools(TOOL_NAMES openssl AUTO_CLEAN)
else()
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/bin/c_rehash.pl"
        "${release_programfiles}/Common Files/SSL/misc/CA.pl"
        "${release_programfiles}/Common Files/SSL/misc/tsget.pl"
        )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE # to pass empty directories check
    "${release_programfiles}/Common Files/SSL/certs"
    "${release_programfiles}/Common Files/SSL/misc"
    "${release_programfiles}/Common Files/SSL/private"
)
