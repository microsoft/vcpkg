function(install_pc_file name pc_data)
    # fix platform-specific details
    if (NOT VCPKG_TARGET_IS_WINDOWS)
        string(REPLACE "-lcrypt32" "" pc_data "${pc_data}")
        string(REPLACE "-lws2_32" "" pc_data "${pc_data}")
        string(REPLACE "-llibssl" "-lssl" pc_data "${pc_data}")
        string(REPLACE "-llibcrypto" "-lcrypto" pc_data "${pc_data}")
    elseif (NOT VCPKG_TARGET_IS_MINGW)
        string(REPLACE "-llibssl" "-lssl" pc_data "${pc_data}")
        string(REPLACE "-llibcrypto" "-lcrypto" pc_data "${pc_data}")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/openssl.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${name}.pc" @ONLY)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        if(VCPKG_TARGET_IS_WINDOWS)
            if (NOT VCPKG_TARGET_IS_MINGW)
                string(REPLACE "-lssl" "-lssld" pc_data "${pc_data}")
                string(REPLACE "-lcrypto" "-lcryptod" pc_data "${pc_data}")
            else()
                string(REPLACE "-llibssl" "-llibssld" pc_data "${pc_data}")
                string(REPLACE "-llibcrypto" "-llibcryptod" pc_data "${pc_data}")
            endif()
        endif()
        configure_file("${CMAKE_CURRENT_LIST_DIR}/openssl.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${name}.pc" @ONLY)
    endif()
endfunction()

install_pc_file(openssl [[
Name: BoringSSL
Description: Secure Sockets Layer and cryptography libraries and tools
Requires: libssl libcrypto
]])

install_pc_file(libssl [[
Name: BoringSSL-libssl
Description: Secure Sockets Layer and cryptography libraries
Libs: -L"${libdir}" -llibssl
Requires: libcrypto
Cflags: -I"${includedir}"
]])

install_pc_file(libcrypto [[
Name: BoringSSL-libcrypto
Description: OpenSSL cryptography library
Libs: -L"${libdir}" -llibcrypto
Libs.private: -lcrypt32 -lws2_32
Cflags: -I"${includedir}"
]])

vcpkg_fixup_pkgconfig()
