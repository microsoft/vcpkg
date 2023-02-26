if (VCPKG_TARGET_IS_LINUX)
    message(NOTICE [[
openssl requires Linux kernel headers from the system package manager.
   They can be installed on Alpine systems via `apk add linux-headers`.
   They can be installed on Ubuntu systems via `apt install linux-libc-dev`.
]])
endif()

if(CMAKE_HOST_WIN32)
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

if(VCPKG_TARGET_IS_ANDROID)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(OPENSSL_ARCH android-arm64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(OPENSSL_ARCH android-arm)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(OPENSSL_ARCH android-x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(OPENSSL_ARCH android-x86)
    else()
        message(FATAL_ERROR "Unknown iOS target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
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
    list(APPEND CONFIGURE_OPTIONS no-ui no-asm)
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(OPENSSL_ARCH darwin64-arm64)
    else()
        set(OPENSSL_ARCH darwin64-x86_64)
    endif()
elseif(VCPKG_TARGET_IS_FREEBSD OR VCPKG_TARGET_IS_OPENBSD)
    set(OPENSSL_ARCH BSD-generic64)
elseif(VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(OPENSSL_ARCH mingw64)
    else()
        set(OPENSSL_ARCH mingw)
    endif()
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    set(INTERPRETER "$ENV{EMSDK}/upstream/emscripten/emconfigure")
    set(MAKE "$ENV{EMSDK}/upstream/emscripten/emmake")
    set(ENV{MAKE} "${MAKE}")
    vcpkg_list(APPEND CONFIGURE_OPTIONS
        threads
        no-engine
        no-asm
        no-sse2
        no-srtp
        --cross-compile-prefix=
    )
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
vcpkg_install_make(BUILD_TARGET build_sw)
vcpkg_fixup_pkgconfig()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/c_rehash" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/c_rehash")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/c_rehash")
vcpkg_copy_tools(TOOL_NAMES openssl AUTO_CLEAN)

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
