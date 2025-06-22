cmake_minimum_required(VERSION 3.14)

project(mongoose C)

include(GNUInstallDirs)

option(ENABLE_SSL "Build with openssl support" OFF)
option(ENABLE_MBEDTLS "Build with mbedtls support" OFF)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_library(mongoose mongoose.c)
target_include_directories(mongoose PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
set_target_properties(mongoose PROPERTIES PUBLIC_HEADER mongoose.h)

if (ENABLE_SSL)
    find_package(OpenSSL REQUIRED)
    target_compile_options(mongoose PRIVATE -DMG_TLS=2) ##define MG_TLS_OPENSSL 2  // OpenSSL
    target_link_libraries(mongoose PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

if (ENABLE_MBEDTLS)
     find_package(mbedtls REQUIRED)
     target_compile_options(mongoose PRIVATE -DMG_TLS=1) ##define MG_TLS_MBED 1     // mbedTLS
     target_link_libraries(mongoose PRIVATE mbedtls mbedcrypto mbedx509)
endif()

install(TARGETS mongoose EXPORT unofficial-mongoose-config)

install(
    EXPORT unofficial-mongoose-config
    NAMESPACE unofficial::mongoose::
    DESTINATION share/unofficial-mongoose
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
