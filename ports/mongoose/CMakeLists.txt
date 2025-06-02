cmake_minimum_required(VERSION 3.14)

project(mongoose C)

include(GNUInstallDirs)

option(ENABLE_SSL "Build with OpenSSL support" OFF)
option(ENABLE_MBEDTLS "Build with mbedTLS support" OFF)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_library(mongoose mongoose.c)
target_include_directories(mongoose PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
set_target_properties(mongoose PROPERTIES PUBLIC_HEADER mongoose.h)

# OpenSSL support
if (ENABLE_SSL)
    find_package(OpenSSL REQUIRED)
    target_compile_definitions(mongoose PRIVATE MG_TLS=MG_TLS_OPENSSL)
    target_link_libraries(mongoose PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

# mbedTLS support
if (ENABLE_MBEDTLS)
    find_package(MbedTLS CONFIG REQUIRED)
    target_compile_definitions(mongoose PRIVATE MG_TLS=MG_TLS_MBED)
    target_link_libraries(mongoose PRIVATE MbedTLS::mbedcrypto MbedTLS::mbedx509 MbedTLS::mbedtls)
endif()

install(TARGETS mongoose
    EXPORT unofficial-mongoose-config
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(
    EXPORT unofficial-mongoose-config
    NAMESPACE unofficial::mongoose::
    DESTINATION share/unofficial-mongoose
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
