_find_package(${ARGS})

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    if(TARGET unofficial::curlpp::curlpp)
        # Fix CURL dependencies. See:
        # https://github.com/Microsoft/vcpkg/issues/4312

        set(_libs "")

        find_package(CURL REQUIRED)

        set(ZLIB_ROOT ${CMAKE_PREFIX_PATH}) # Prefer Zlib installed via `vcpkg`
        find_package(ZLIB)
        unset(ZLIB_ROOT)

        list(APPEND _libs ${CURL_LIBRARIES} ZLIB::ZLIB)

        find_package(OpenSSL QUIET)
        if(OPENSSL_FOUND)
            list(APPEND _libs OpenSSL::SSL OpenSSL::Crypto)
        endif()

        find_package(Threads REQUIRED)
        list(APPEND _libs Threads::Threads)

        if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
            list(APPEND _libs Ws2_32 Crypt32)
        endif()

        set_target_properties(
            unofficial::curlpp::curlpp
            PROPERTIES INTERFACE_LINK_LIBRARIES "${_libs}"
        )
    endif()
endif()
