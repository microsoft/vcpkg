if (VCPKG_TARGET_IS_LINUX)
    message(NOTICE [[
openssl requires Linux kernel headers from the system package manager.
   They can be installed on Alpine systems via `apk add linux-headers`.
   They can be installed on Ubuntu systems via `apt install linux-libc-dev`.
]])
endif()

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make perl)
    set(MAKE "${MSYS_ROOT}/usr/bin/make.exe")
    set(PERL "${MSYS_ROOT}/usr/bin/perl.exe")
else()
    find_program(MAKE make)
    if(NOT MAKE)
        message(FATAL_ERROR "Could not find make. Please install it through your package manager.")
    endif()
    vcpkg_find_acquire_program(PERL)
endif()
set(INTERPRETER "${PERL}")

execute_process(
    COMMAND "${PERL}" -e "use IPC::Cmd;"
    RESULT_VARIABLE perl_ipc_cmd_result
)
if(NOT perl_ipc_cmd_result STREQUAL "0")
    message(FATAL_ERROR "\nPerl cannot find IPC::Cmd. Please install it through your system package manager.\n")
endif()

# Ideally, OpenSSL should use `CC` from vcpkg as is (absolute path).
# But in reality, OpenSSL expects to locate the compiler via `PATH`,
# and it makes its own choices e.g. for Android.
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
cmake_path(GET VCPKG_DETECTED_CMAKE_C_COMPILER PARENT_PATH compiler_path)
cmake_path(GET VCPKG_DETECTED_CMAKE_C_COMPILER FILENAME compiler_name)
find_program(compiler_in_path NAMES "${compiler_name}" PATHS ENV PATH NO_DEFAULT_PATH)
if(NOT compiler_in_path)
    vcpkg_host_path_list(APPEND ENV{PATH} "${compiler_path}")
elseif(NOT compiler_in_path STREQUAL VCPKG_DETECTED_CMAKE_C_COMPILER)
    vcpkg_host_path_list(PREPEND ENV{PATH} "${compiler_path}")
endif()

vcpkg_list(SET MAKEFILE_OPTIONS)
# Universal builds don't support ASM
list(LENGTH VCPKG_OSX_ARCHITECTURES openssl_osx_arch_count)
if(openssl_osx_arch_count GREATER 1)
    list(APPEND CONFIGURE_OPTIONS no-asm)
endif()
if(VCPKG_TARGET_IS_ANDROID)
    set(ENV{ANDROID_NDK_ROOT} "${VCPKG_DETECTED_CMAKE_ANDROID_NDK}")
    set(OPENSSL_ARCH "android-${VCPKG_DETECTED_CMAKE_ANDROID_ARCH}")
    if(VCPKG_DETECTED_CMAKE_ANDROID_ARCH STREQUAL "arm" AND NOT VCPKG_DETECTED_CMAKE_ANDROID_ARM_NEON)
        vcpkg_list(APPEND CONFIGURE_OPTIONS no-asm)
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(OPENSSL_ARCH linux-aarch64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(OPENSSL_ARCH linux-armv4)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(OPENSSL_ARCH linux-x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(OPENSSL_ARCH linux-x86)
    else()
        set(OPENSSL_ARCH linux-generic32)
    endif()
elseif(VCPKG_TARGET_IS_IOS)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(OPENSSL_ARCH ios64-xcrun)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(OPENSSL_ARCH ios-xcrun)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" OR VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(OPENSSL_ARCH iossimulator-xcrun)
    else()
        message(FATAL_ERROR "Unknown iOS target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    # disable that makes linkage error (e.g. require stderr usage)
    list(APPEND CONFIGURE_OPTIONS no-ui)
elseif(VCPKG_TARGET_IS_TVOS OR VCPKG_TARGET_IS_WATCHOS)
    set(OPENSSL_ARCH iphoneos-cross)
    # disable that makes linkage error (e.g. require stderr usage)
    list(APPEND CONFIGURE_OPTIONS no-ui no-asm)
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(OPENSSL_ARCH darwin64-arm64)
    else()
        set(OPENSSL_ARCH darwin64-x86_64)
    endif()
elseif(VCPKG_TARGET_IS_BSD)
    set(OPENSSL_ARCH BSD-nodef-generic64)
elseif(VCPKG_TARGET_IS_SOLARIS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(OPENSSL_ARCH solaris64-x86_64-gcc)
    else()
        set(OPENSSL_ARCH solaris-x86-gcc)
    endif()
elseif(VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(OPENSSL_ARCH mingw64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(OPENSSL_ARCH mingwarm64)
    else()
        set(OPENSSL_ARCH mingw)
    endif()
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    set(OPENSSL_ARCH linux-x32)
    vcpkg_list(APPEND CONFIGURE_OPTIONS
        no-engine
        no-asm
        no-sse2
        no-srtp
        --cross-compile-prefix=
    )
    # Cf. https://emscripten.org/docs/porting/pthreads.html:
    # For Pthreads support, not just openssl but everything
    # must be compiled and linked with `-pthread`.
    # This makes it a triplet/toolchain-wide setting.
    if(NOT " ${VCPKG_DETECTED_CMAKE_C_FLAGS} " MATCHES " -pthread ")
        vcpkg_list(APPEND CONFIGURE_OPTIONS no-threads)
    endif()
elseif(VCPKG_TARGET_IS_WINDOWS)
    # clang with the GNU-style driver targeting windows-msvc. The Configure
    # target adds what the environment cannot: the target triple, the CRT
    # selection, Windows system defines and link libraries, the perlasm
    # flavor and the DLL link rules.
    if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        message(FATAL_ERROR "Only x64 is implemented for clang targeting windows-msvc")
    endif()
    # The FIPS provider is a loadable module, and modules stay disabled here.
    if("fips" IN_LIST FEATURES)
        message(FATAL_ERROR "Feature fips is not supported when building with clang targeting windows-msvc")
    endif()
    set(OPENSSL_ARCH mingw-clang-msvc64)
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(OPENSSL_MS_RUNTIME_LIB static)
    else()
        set(OPENSSL_MS_RUNTIME_LIB dll)
    endif()
    configure_file("${CMAKE_CURRENT_LIST_DIR}/90-clang-windows.conf.in" "${SOURCE_PATH}/Configurations/90-clang-windows.conf" @ONLY)
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/ClangWindows.pm" DESTINATION "${SOURCE_PATH}/Configurations/platform")
    # Providers are linked into libcrypto instead of loaded as modules.
    vcpkg_list(APPEND CONFIGURE_OPTIONS no-module no-dso no-engine)
    # perlasm asks $(CC) without CFLAGS for the symbol prefix: give it the target, or a macOS host answers "_"
    # The compiler is named rather than given by path: make splits variables on
    # spaces (C:/Program Files/LLVM), and its directory leads PATH (see above).
    set(make_vars "CC=${compiler_name} --target=x86_64-pc-windows-msvc")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" OR "tools" IN_LIST FEATURES)
        # The DLLs and openssl.exe carry version resources in windres syntax.
        # llvm-windres is llvm-rc started under a name containing "windres";
        # LLVM release packages ship only llvm-rc, so fall back to a copy.
        find_program(LLVM_WINDRES NAMES llvm-windres PATHS "${compiler_path}" NO_DEFAULT_PATH)
        if(NOT LLVM_WINDRES)
            find_program(LLVM_RC NAMES llvm-rc PATHS "${compiler_path}" NO_DEFAULT_PATH)
            if(NOT LLVM_RC)
                message(FATAL_ERROR "Neither llvm-windres nor llvm-rc was found next to ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            endif()
            set(LLVM_WINDRES "${CURRENT_BUILDTREES_DIR}/llvm-windres${VCPKG_HOST_EXECUTABLE_SUFFIX}")
            file(COPY_FILE "${LLVM_RC}" "${LLVM_WINDRES}")
        endif()
        # Preprocess with the C compiler and its flags, so the resource sees
        # the same target and SDK headers (winver.h) as the C sources.
        string(REPLACE "'" "'\\''" quoted_compiler "${compiler_name}")
        string(REPLACE "$" "$$" quoted_compiler "${quoted_compiler}")
        set(rc_flags "--target=pe-x86-64 '--preprocessor=${quoted_compiler}'")
        separate_arguments(c_flags NATIVE_COMMAND "-E -xc -DRC_INVOKED --target=x86_64-pc-windows-msvc ${VCPKG_DETECTED_CMAKE_C_FLAGS}")
        foreach(flag IN LISTS c_flags)
            string(REPLACE "'" "'\\''" quoted_flag "${flag}")
            string(REPLACE "$" "$$" quoted_flag "${quoted_flag}")
            string(APPEND rc_flags " '--preprocessor-arg=${quoted_flag}'")
        endforeach()
        string(REPLACE "'" "'\\''" quoted_windres "${LLVM_WINDRES}")
        string(REPLACE "$" "$$" quoted_windres "${quoted_windres}")
        vcpkg_list(APPEND make_vars "RC='${quoted_windres}'" "RCFLAGS=${rc_flags}")
    endif()
    vcpkg_list(APPEND MAKEFILE_OPTIONS OPTIONS ${make_vars})
else()
    message(FATAL_ERROR "Unknown platform")
endif()

file(MAKE_DIRECTORY "${SOURCE_PATH}/vcpkg")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}/vcpkg")
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "vcpkg"
    NO_ADDITIONAL_PATHS
    OPTIONS
        "${INTERPRETER}"
        "${SOURCE_PATH}/Configure"
        ${OPENSSL_ARCH}
        ${CONFIGURE_OPTIONS}
        "--openssldir=/etc/ssl"
        "--libdir=lib"
    OPTIONS_DEBUG
        --debug
)
vcpkg_install_make(
    ${MAKEFILE_OPTIONS}
    BUILD_TARGET build_inst_sw
)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libssl.pc" "-L\${libdir} -lssl" "-L\${libdir} -llibssl")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libcrypto.pc" "-L\${libdir} -lcrypto" "-L\${libdir} -llibcrypto")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libssl.pc" "-L\${libdir} -lssl" "-L\${libdir} -llibssl")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libcrypto.pc" "-L\${libdir} -lcrypto" "-L\${libdir} -llibcrypto")
    endif()
endif()
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/c_rehash" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/c_rehash")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/c_rehash")
    vcpkg_copy_tools(TOOL_NAMES openssl AUTO_CLEAN)
else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    # Only the apps install scripts here.
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc/ssl/misc")
endif()

file(TOUCH "${CURRENT_PACKAGES_DIR}/etc/ssl/certs/.keep")
file(TOUCH "${CURRENT_PACKAGES_DIR}/etc/ssl/private/.keep")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# For consistency of mingw build with nmake build
file(GLOB engines "${CURRENT_PACKAGES_DIR}/lib/ossl-modules/*.dll")
if(NOT engines STREQUAL "")
    file(COPY ${engines} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/ossl-modules")
endif()
file(GLOB engines "${CURRENT_PACKAGES_DIR}/debug/lib/ossl-modules/*.dll")
if(NOT engines STREQUAL "")
    file(COPY ${engines} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/ossl-modules")
endif()
