cmake_minimum_required(VERSION 3.7)
project(libressl-test C)

find_package(PkgConfig REQUIRED)

# libressl provides cmake config
find_package(LibreSSL CONFIG REQUIRED)
message(STATUS "LibreSSL CONFIG: ${LibreSSL_DIR}")
string(FIND "${LibreSSL_DIR}" "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" index)
if(NOT index STREQUAL "0")
    message(SEND_ERROR "LibreSSL CONFIG is not from vcpkg.")
endif()

pkg_check_modules(libtls IMPORTED_TARGET REQUIRED libtls)
if(NOT libtls_VERSION STREQUAL LibreSSL_VERSION)
    message(SEND_ERROR "Unexpected libtls_VERSION '${libtls_VERSION}' (expected: '${LibreSSL_VERSION}')")
endif()

# libressl promises openssl compatibility
# NB: The port doesn't provide a wrapper, so there is no support
#     for multi-config and for transitive usage requirements.
find_package(OpenSSL MODULE REQUIRED)
foreach(target IN ITEMS OpenSSL::SSL OpenSSL::Crypto)
    set(location_found FALSE)
    foreach(property IN ITEMS IMPORTED_LOCATION IMPORTED_LOCATION_DEBUG IMPORTED_LOCATION_RELEASE)
        get_target_property(location ${target} ${property})
        if(NOT location)
            continue()
        endif()
        set(location_found TRUE)
        message(STATUS "${target} ${property}: ${location}")
        string(FIND "${location}" "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" index)
        if(NOT index STREQUAL "0")
            message(SEND_ERROR "${target} ${property} is not from vcpkg.")
        endif()
    endforeach()
    if(NOT location_found)
        message(SEND_ERROR "No location for ${target} binary")
    endif()
endforeach()
if(NOT OPENSSL_VERSION STREQUAL "2.0.0")
    message(SEND_ERROR "Unexpected OPENSSL_VERSION '${OPENSSL_VERSION}' (expected: '2.0.0')")
endif()

pkg_check_modules(openssl IMPORTED_TARGET REQUIRED openssl)
# NB: openssl.pc carries libressl version (3.x), but doesn't provide 3.x OpenSSL API.
if(NOT openssl_VERSION STREQUAL LibreSSL_VERSION)
    message(SEND_ERROR "Unexpected openssl_VERSION '${openssl_VERSION}' (expected: '${LibreSSL_VERSION}')")
endif()

# compile and link tests

add_executable(openssl_cmake openssl.c)
target_link_libraries(openssl_cmake OpenSSL::SSL)

add_executable(openssl_pkgconfig openssl.c)
target_link_libraries(openssl_pkgconfig PkgConfig::openssl)

add_executable(libressl_cmake libressl.c)
target_link_libraries(libressl_cmake LibreSSL::TLS)

add_executable(libressl_pkgconfig libressl.c)
target_link_libraries(libressl_pkgconfig PkgConfig::libtls)
