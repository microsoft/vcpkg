# Unofficial uSockets CMakeLists.txt from Makefile of https://github.com/uNetworking/uSockets/blob/v0.8.8/Makefile
cmake_minimum_required(VERSION 3.25.1)
project(uSockets VERSION ${VERSION} LANGUAGES C CXX)

# options

option(WITH_LTO         "use LTO"                                                           ON)

option(WITH_BORINGSSL   "enables BoringSSL support (preferred over OpenSSL)"                OFF)
option(WITH_OPENSSL     "enables OpenSSL 1.1+ support"                                      OFF)
option(WITH_WOLFSSL     "enables WolfSSL 4.2.0 support (mutually exclusive with OpenSSL)"   OFF)

option(WITH_IO_URING    "builds with io_uring as event-loop and network implementation"     OFF)
option(WITH_LIBUV       "builds with libuv as event-loop"                                   OFF)
option(WITH_ASIO        "builds with boot asio event-loop"                                  OFF)
option(WITH_GCD         "builds with libdispatch as event-loop"                             OFF)

option(WITH_ASAN        "builds with sanitizers"                                            OFF)
option(WITH_QUIC        "Experimental QUIC"                                                 OFF)

option(BUILD_EXAMPLES   "Builds all examples"                                               ON)

# global variables

set(uSockets_installable_libs)
set(PACKAGE_DEPENDCIES_ITEM_LIST)

# global setting

if(WITH_LTO)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
endif(WITH_LTO)

# target usockets

add_library(uSockets)
if(TARGET uSockets)
    list(APPEND uSockets_installable_libs uSockets)
    foreach(dir IN ITEMS "src" "src/eventing" "src/crypto" "src/io_uring")
        aux_source_directory(${dir} uSockets_sources)
    endforeach()
    list(FILTER uSockets_sources INCLUDE REGEX ".+\\.c$")
    target_sources(uSockets PRIVATE ${uSockets_sources})
    if(WIN32)
        target_link_libraries(uSockets PRIVATE ws2_32)
    endif(WIN32)
endif(TARGET uSockets)

# target coupling options

add_library(us_target_coupling INTERFACE)
if(TARGET us_target_coupling)
    list(APPEND uSockets_installable_libs us_target_coupling)
    # global include
    target_include_directories(us_target_coupling INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>")

    # global std
    target_compile_features(us_target_coupling INTERFACE "c_std_11")
    if(WITH_OPENSSL OR WITH_BORINGSSL)
        target_compile_features(us_target_coupling INTERFACE "cxx_std_17")
    else()
        target_compile_features(us_target_coupling INTERFACE "cxx_std_14")
    endif()

    # ssl
    if(TRUE)
        if(WITH_BORINGSSL)
            target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_BORINGSSL")

            find_package(OpenSSL REQUIRED)
            list(APPEND PACKAGE_DEPENDCIES_ITEM_LIST "OpenSSL REQUIRED")
            target_link_libraries(us_target_coupling INTERFACE OpenSSL::SSL OpenSSL::Crypto)

            set(THREADS_PREFER_PTHREAD_FLAG ON)
            find_package(Threads REQUIRED)
            list(APPEND PACKAGE_DEPENDCIES_ITEM_LIST "Threads REQUIRED")
            target_link_libraries(us_target_coupling INTERFACE Threads::Threads)

        elseif(WITH_OPENSSL)
            target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_OPENSSL")
            find_package(OpenSSL REQUIRED)
            list(APPEND PACKAGE_DEPENDCIES_ITEM_LIST "OpenSSL REQUIRED")
            target_link_libraries(us_target_coupling INTERFACE OpenSSL::SSL OpenSSL::Crypto)

        elseif(WITH_WOLFSSL)
            target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_WOLFSSL")
            find_package(WolfSSL REQUIRED)
            list(APPEND PACKAGE_DEPENDCIES_ITEM_LIST "WolfSSL REQUIRED")
            target_link_libraries(us_target_coupling INTERFACE WolfSSL::WolfSSL)

        else()
            target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_NO_SSL")

        endif()
    endif(TRUE)

    # event-loop and network
    if(WITH_IO_URING)       # io_uring event-loop and network implementation
        message(FATAL_ERROR "WITH_IO_URING is not supported yet")
        target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_IO_URING")
        # find_package()

    else()                  # event-loop

        if(WITH_LIBUV)
            target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_LIBUV")
            find_package(libuv CONFIG REQUIRED)
            list(APPEND PACKAGE_DEPENDCIES_ITEM_LIST "libuv CONFIG REQUIRED")
            target_link_libraries(us_target_coupling INTERFACE $<IF:$<TARGET_EXISTS:libuv::uv_a>,libuv::uv_a,libuv::uv>)

        elseif(WITH_ASIO)
            message(FATAL_ERROR "WITH_ASIO is not supported yet")
            target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_ASIO")
            # find_package()

        elseif(WITH_GCD)
            message(FATAL_ERROR "WITH_GCD is not supported yet")
            target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_GCD")
            # target_link_options(us_target_coupling INTERFACE "-framework CoreFoundation")

        else()
            string(COMPARE EQUAL CMAKE_SYSTEM_NAME "FreeBSD" IS_FreeBSD)
            if(WIN32)
                message(FATAL_ERROR "Windows should use LIBUV as default event loop")
            elseif(APPLE OR (CMAKE_SYSTEM_NAME STREQUAL "FreeBSD"))
                message("Apple or FreeBSD use KQUEUE as default event loop")
            else()
                message("Use EPOLL as default event loop")
            endif()

        endif()

    endif()

    # asan
    if(WITH_ASAN)
        message(FATAL_ERROR "WITH_ASAN is not supported yet")
        # target_compile_options(us_target_coupling INTERFACE "-fsanitize=address")

    endif(WITH_ASAN)

    # quic
    if(WITH_QUIC)
        message(FATAL_ERROR "WITH_QUIC is not supported yet")
        target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_QUIC")
        # find_package(lsquic REQUIRED)
        # set(THREADS_PREFER_PTHREAD_FLAG ON)
        # find_package(Threads REQUIRED)
        # find_package(ZLIB REQUIRED)
        # target_link_libraries(us_target_coupling PRIVATE m)
    endif(WITH_QUIC)

    target_link_libraries(uSockets PRIVATE us_target_coupling)

endif(TARGET us_target_coupling)

# target asio

if(WITH_ASIO)
    add_library(us_target_asio PRIVATE "src/eventing/asio.cpp")
    list(APPEND uSockets_installable_libs us_target_asio)
    target_link_libraries(us_target_asio PUBLIC us_target_coupling)
    target_link_libraries(uSockets PRIVATE us_target_asio)
endif(WITH_ASIO)

# target crypto

if(WITH_OPENSSL OR WITH_BORINGSSL)
    add_library(us_target_crypto)
    list(APPEND uSockets_installable_libs us_target_crypto)
    foreach(dir IN ITEMS "src/crypto")
        aux_source_directory(${dir} us_target_crypto_sources)
    endforeach()
    list(FILTER us_target_crypto_sources INCLUDE REGEX ".+\\.cpp$")
    target_sources(us_target_crypto PRIVATE ${us_target_crypto_sources})
    target_link_libraries(us_target_crypto PUBLIC us_target_coupling)
    target_link_libraries(uSockets PRIVATE us_target_crypto)
endif()

# examples

# TODO

# install init

set(PACKAGE_NAME "unofficial-uSockets")
set(PACKAGE_NAMESPACE "unofficial::uSockets::")
set(PACKAGE_CONFIG_NAME "${PACKAGE_NAME}Config")
set(PACKAGE_INSTALL_SHARE "share/${PACKAGE_NAME}")
set(PACKAGE_INSTALL_INCLUDE "include/${PACKAGE_NAME}")
set(uSockets_targets_name "uSocketsTargets")
set(PACKAGE_CONFIG_TEMPLATE_PATH "${CMAKE_CURRENT_BINARY_DIR}/Config.cmake.in")
file(GLOB PACKAGE_HEADERS "src/*.h")

# install headers

target_include_directories(uSockets PUBLIC "$<INSTALL_INTERFACE:${PACKAGE_INSTALL_INCLUDE}>")
install(FILES ${PACKAGE_HEADERS} DESTINATION ${PACKAGE_INSTALL_INCLUDE})

# install targets

install(TARGETS ${uSockets_installable_libs}
    EXPORT ${uSockets_targets_name}
)

install(EXPORT ${uSockets_targets_name}
    NAMESPACE ${PACKAGE_NAMESPACE}
    DESTINATION ${PACKAGE_INSTALL_SHARE}
)

# config generate

set(PACKAGE_CONFIG_TEMPLATE "@PACKAGE_INIT@\n\n")
string(APPEND PACKAGE_CONFIG_TEMPLATE "include(CMakeFindDependencyMacro)\n")
list(REMOVE_DUPLICATES PACKAGE_DEPENDCIES_ITEM_LIST)
foreach(dep IN LISTS PACKAGE_DEPENDCIES_ITEM_LIST)
    string(APPEND PACKAGE_CONFIG_TEMPLATE "find_dependency(${dep})\n")
endforeach()
string(APPEND PACKAGE_CONFIG_TEMPLATE "\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/${uSockets_targets_name}.cmake\")\n")

file(WRITE ${PACKAGE_CONFIG_TEMPLATE_PATH} ${PACKAGE_CONFIG_TEMPLATE})

include(CMakePackageConfigHelpers)
configure_package_config_file("${PACKAGE_CONFIG_TEMPLATE_PATH}"
  "${PACKAGE_CONFIG_NAME}.cmake"
  INSTALL_DESTINATION "${PACKAGE_INSTALL_SHARE}"
)

# install config

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_CONFIG_NAME}.cmake" DESTINATION ${PACKAGE_INSTALL_SHARE})
