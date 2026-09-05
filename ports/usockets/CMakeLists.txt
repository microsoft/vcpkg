cmake_minimum_required(VERSION 3.30)
project(uSockets C CXX)

option(WITH_OPENSSL "Enables OpenSSL 1.1+ support")

# Upstream compiles all sources at once
option(CMAKE_UNITY_BUILD "Combine source for compilation." ON)

file(GLOB C_SOURCES src/*.c src/eventing/*.c)
add_library(uSockets ${C_SOURCES})
set_target_properties(uSockets PROPERTIES EXPORT_NAME usockets)
target_include_directories(uSockets
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>"
        "$<INSTALL_INTERFACE:include>"
)

if(WITH_OPENSSL)
    file(GLOB CRYPTO_SOURCES src/crypto/*.c*)
    target_sources(uSockets PRIVATE ${CRYPTO_SOURCES})
    target_compile_features(uSockets PRIVATE cxx_std_17)
    # https://github.com/uNetworking/uSockets/blob/0ebdde0601cc82349fc11a7c4bbb6dc5c9f28f42/Makefile#L55
    find_package(OpenSSL REQUIRED)
    target_link_libraries(uSockets PRIVATE OpenSSL::SSL OpenSSL::Crypto)
    target_compile_definitions(uSockets PRIVATE -DLIBUS_USE_OPENSSL)
else()
    target_compile_definitions(uSockets PRIVATE -DLIBUS_NO_SSL)
endif()

if(WIN32 OR ANDROID)
    # https://github.com/uNetworking/uSockets/blob/8606de6414a102c55bef8e8ef3391932d7e8df6a/src/libusockets.h#L339-L348
    find_package(libuv CONFIG REQUIRED)
    target_link_libraries(uSockets PRIVATE $<IF:$<TARGET_EXISTS:libuv::uv_a>,libuv::uv_a,libuv::uv>)
    target_compile_definitions(uSockets PRIVATE -DLIBUS_USE_LIBUV)

    if(WIN32)
        # https://github.com/uNetworking/uSockets/blob/8606de6414a102c55bef8e8ef3391932d7e8df6a/src/libusockets.h#L35
        target_link_libraries(uSockets PRIVATE ws2_32)
    endif()
endif()


install(TARGETS uSockets
    EXPORT unofficial-usockets-targets
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(EXPORT unofficial-usockets-targets
    NAMESPACE unofficial::usockets::
    DESTINATION share/unofficial-usockets
)

configure_file("unofficial-usockets-config.cmake" "${CMAKE_CURRENT_BINARY_DIR}/unofficial-usockets-config.cmake" @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-usockets-config.cmake"
    DESTINATION share/unofficial-usockets
)

install(FILES src/libusockets.h DESTINATION include)
