cmake_minimum_required(VERSION 3.7)
project(libressl-test CXX)

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

# libressl provides cmake config
find_package(LibreSSL CONFIG REQUIRED)
message(STATUS "LibreSSL CONFIG: ${LibreSSL_DIR}")
string(FIND "${LibreSSL_DIR}" "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" index)
if(NOT index STREQUAL "0")
    message(SEND_ERROR "LibreSSL CONFIG is not from vcpkg.")
endif()
