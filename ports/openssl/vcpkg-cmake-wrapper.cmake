set(OPENSSL_ROOT_DIR_BAK ${OPENSSL_ROOT_DIR})
get_filename_component(OPENSSL_ROOT_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(OPENSSL_ROOT_DIR "${OPENSSL_ROOT_DIR}" PATH)
get_filename_component(OPENSSL_ROOT_DIR "${OPENSSL_ROOT_DIR}" PATH)

file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" Z_VCPKG_PROGRAMFILES)
set(Z_VCPKG_PROGRAMFILESX86_NAME "PROGRAMFILES(x86)")
file(TO_CMAKE_PATH "$ENV{${Z_VCPKG_PROGRAMFILESX86_NAME}}" Z_VCPKG_PROGRAMFILESX86)
set(CMAKE_SYSTEM_IGNORE_PATH
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win32"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win64"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win32/lib/VC"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win64/lib/VC"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win32/lib/VC/static"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win64/lib/VC/static"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win32"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win64"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win32/lib/VC"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win64/lib/VC"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win32/lib/VC/static"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win64/lib/VC/static"
    "C:/OpenSSL/"
    "C:/OpenSSL-Win32/"
    "C:/OpenSSL-Win64/"
    "C:/OpenSSL-Win32/lib/VC"
    "C:/OpenSSL-Win64/lib/VC"
    "C:/OpenSSL-Win32/lib/VC/static"
    "C:/OpenSSL-Win64/lib/VC/static"
)

_find_package(${ARGS})

if(OPENSSL_FOUND)
    if("@OPENSSL_USE_WINDOWS_CMAKE_WRAPPER@")
        list(APPEND OPENSSL_LIBRARIES crypt32.lib ws2_32.lib)
        if(TARGET OpenSSL::Crypto)
            set_property(TARGET OpenSSL::Crypto APPEND PROPERTY INTERFACE_LINK_LIBRARIES "crypt32.lib;ws2_32.lib")
        endif()
        if(TARGET OpenSSL::SSL)
            set_property(TARGET OpenSSL::SSL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "crypt32.lib;ws2_32.lib")
        endif()
    endif()

    if("@OPENSSL_USE_UNIX_CMAKE_WRAPPER@")
        find_library(OPENSSL_DL_LIBRARY NAMES dl)
        if(OPENSSL_DL_LIBRARY)
            list(APPEND OPENSSL_LIBRARIES "dl")
            if(TARGET OpenSSL::Crypto)
                set_property(TARGET OpenSSL::Crypto APPEND PROPERTY INTERFACE_LINK_LIBRARIES "dl")
            endif()
        endif()
        find_package(Threads REQUIRED)
        list(APPEND OPENSSL_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
        if(TARGET OpenSSL::Crypto)
            set_property(TARGET OpenSSL::Crypto APPEND PROPERTY INTERFACE_LINK_LIBRARIES "Threads::Threads")
        endif()
        if(TARGET OpenSSL::SSL)
            set_property(TARGET OpenSSL::SSL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "Threads::Threads")
        endif()
    endif()
endif()

set(OPENSSL_ROOT_DIR ${OPENSSL_ROOT_DIR_BAK})
