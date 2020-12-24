cmake_minimum_required(VERSION 3.8)
project(cppcoro VERSION 2020.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

add_library(cppcoro
    lib/async_mutex.cpp 
    lib/lightweight_manual_reset_event.cpp
    lib/async_auto_reset_event.cpp
    lib/async_manual_reset_event.cpp
    lib/auto_reset_event.cpp
    lib/auto_reset_event.hpp
    lib/cancellation_registration.cpp
    lib/cancellation_source.cpp
    lib/cancellation_state.cpp
    lib/cancellation_state.hpp
    lib/cancellation_token.cpp
    lib/spin_mutex.cpp
    lib/spin_mutex.hpp
    lib/spin_wait.cpp
    lib/spin_wait.hpp
    lib/static_thread_pool.cpp
    lib/ip_address.cpp
    lib/ip_endpoint.cpp
    lib/ipv4_address.cpp
    lib/ipv4_endpoint.cpp
    lib/ipv6_address.cpp
    lib/ipv6_endpoint.cpp
)

if(APPLE)
    message(STATUS "using sysroot: ${CMAKE_OSX_SYSROOT}")
elseif(WIN32)
    message(STATUS "using platform: ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}")
    # for now, build in single target
    target_sources(cppcoro
    PRIVATE
        lib/win32.cpp
        lib/file.cpp
        lib/file_read_operation.cpp
        lib/file_write_operation.cpp
        lib/read_only_file.cpp
        lib/read_write_file.cpp
        lib/readable_file.cpp
        lib/writable_file.cpp
        lib/write_only_file.cpp
        lib/socket.cpp
        lib/socket_accept_operation.cpp
        lib/socket_connect_operation.cpp
        lib/socket_send_operation.cpp
        lib/socket_send_to_operation.cpp
        lib/socket_disconnect_operation.cpp
        lib/socket_helpers.cpp
        lib/socket_helpers.hpp
        lib/socket_recv_from_operation.cpp
        lib/socket_recv_operation.cpp
        lib/io_service.cpp
    )
elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
    message(STATUS "using system: ${CMAKE_HOST_SYSTEM_VERSION}")
endif()

target_include_directories(cppcoro
PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    if(WIN32)
        message(FATAL_ERROR "<experimental/resumable> doesn't support clang-cl compiler")
    else()
        target_compile_options(cppcoro
        PUBLIC
            -std=c++1z -fcoroutines-ts
            -stdlib=libc++
        )
        target_link_libraries(cppcoro
        PUBLIC
            c++ pthread
        )
    endif()

elseif(MSVC)
    target_compile_options(cppcoro
    PUBLIC
        /await
    PRIVATE
        "/analyze:max_paths 512"
        -D_SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING=1
    )
    if(CMAKE_GENERATOR_PLATFORM STREQUAL x64)
        target_compile_options(cppcoro
        PUBLIC
            /await:heapelide
        )
    endif()

endif()

if(WIN32)
    target_link_libraries(cppcoro
    PUBLIC
        kernel32 synchronization ws2_32 mswsock
        # msvcrt[d] msvcprt[d] vcruntime ucrt
    )
elseif(APPLE)

elseif(CMAKE_SYSTEM_NAME MATCHES Linux)
    target_link_libraries(cppcoro
    PUBLIC
        c++ # stdc++ # expect libc++ instead of libstdc++
    )
endif()

install(DIRECTORY   include/cppcoro
        DESTINATION include
)

install(TARGETS     cppcoro
        EXPORT      ${PROJECT_NAME}-config
        RUNTIME     DESTINATION bin
        LIBRARY     DESTINATION lib
        ARCHIVE     DESTINATION lib
)

install(EXPORT      ${PROJECT_NAME}-config
        DESTINATION share/${PROJECT_NAME}
)

include(CMakePackageConfigHelpers)
set(VERSION_FILE_PATH   ${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}-config-version.cmake)
write_basic_package_version_file(${VERSION_FILE_PATH}
    VERSION             ${PROJECT_VERSION}
    COMPATIBILITY       SameMajorVersion
)

install(FILES           ${VERSION_FILE_PATH} 
        DESTINATION     share/${PROJECT_NAME}
)

if(NOT BUILD_TESTING)
    return()
endif()
enable_testing()
find_package(Threads REQUIRED)

add_executable(cppcoro_test
    test/main.cpp   test/counted.cpp
    test/generator_tests.cpp
    # test/recursive_generator_tests.cpp    # clang crash
    test/async_generator_tests.cpp
    test/async_auto_reset_event_tests.cpp
    test/async_manual_reset_event_tests.cpp
    test/async_mutex_tests.cpp
    test/async_latch_tests.cpp
    test/cancellation_token_tests.cpp
    test/task_tests.cpp
    test/sequence_barrier_tests.cpp
    test/shared_task_tests.cpp
    test/sync_wait_tests.cpp
    test/single_consumer_async_auto_reset_event_tests.cpp
    test/single_producer_sequencer_tests.cpp
    test/multi_producer_sequencer_tests.cpp
    test/when_all_tests.cpp
    test/when_all_ready_tests.cpp
    test/ip_address_tests.cpp
    test/ip_endpoint_tests.cpp
    test/ipv4_address_tests.cpp
    test/ipv4_endpoint_tests.cpp
    test/ipv6_address_tests.cpp
    test/ipv6_endpoint_tests.cpp
    test/static_thread_pool_tests.cpp
)

target_link_libraries(cppcoro_test
PRIVATE
    cppcoro
    Threads::Threads
)

find_package(doctest CONFIG REQUIRED)
get_target_property(DOCTEST_INCLUDE_DIR doctest::doctest
    INTERFACE_INCLUDE_DIRECTORIES
)
message(STATUS "using doctest: ${DOCTEST_INCLUDE_DIR}")
target_link_libraries(cppcoro_test
PRIVATE
    doctest::doctest
)

if(WIN32)
    target_sources(cppcoro_test
    PRIVATE
        test/scheduling_operator_tests.cpp
        test/io_service_tests.cpp
        test/file_tests.cpp
        test/socket_tests.cpp
    )
endif()

add_test(NAME test_all COMMAND cppcoro_test --duration=true )