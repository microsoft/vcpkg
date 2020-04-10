
cmake_minimum_required(VERSION 3.8)
project(cppcoro VERSION 2020.2 LANGUAGES CXX)

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

set_target_properties(cppcoro
PROPERTIES
    CXX_STANDARD 17 # expect C++ Coroutines TS <experimental/coroutine>
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
    list(APPEND detail_headers
        include/cppcoro/detail/win32.hpp
        include/cppcoro/detail/win32_overlapped_operation.hpp
    )
    list(APPEND net_headers
        include/cppcoro/net/socket.hpp
        include/cppcoro/net/socket_accept_operation.hpp
        include/cppcoro/net/socket_connect_operation.hpp
        include/cppcoro/net/socket_disconnect_operation.hpp
        include/cppcoro/net/socket_recv_operation.hpp
        include/cppcoro/net/socket_recv_from_operation.hpp
        include/cppcoro/net/socket_send_operation.hpp
        include/cppcoro/net/socket_send_to_operation.hpp
    )
    set_target_properties(cppcoro
    PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS true
    )

elseif(CMAKE_SYSTEM_NAME MATCHES Linux)
    message(STATUS "using system: ${CMAKE_HOST_SYSTEM_VERSION}")

endif()

list(APPEND headers
    include/cppcoro/awaitable_traits.hpp
    include/cppcoro/is_awaitable.hpp
    include/cppcoro/async_auto_reset_event.hpp
    include/cppcoro/async_manual_reset_event.hpp
    include/cppcoro/async_generator.hpp
    include/cppcoro/async_mutex.hpp
    include/cppcoro/async_latch.hpp
    include/cppcoro/async_scope.hpp
    include/cppcoro/broken_promise.hpp
    include/cppcoro/cancellation_registration.hpp
    include/cppcoro/cancellation_source.hpp
    include/cppcoro/cancellation_token.hpp
    include/cppcoro/task.hpp
    include/cppcoro/sequence_barrier.hpp
    include/cppcoro/sequence_traits.hpp
    include/cppcoro/single_producer_sequencer.hpp
    include/cppcoro/multi_producer_sequencer.hpp
    include/cppcoro/shared_task.hpp
    include/cppcoro/single_consumer_event.hpp
    include/cppcoro/single_consumer_async_auto_reset_event.hpp
    include/cppcoro/sync_wait.hpp
    include/cppcoro/task.hpp
    include/cppcoro/io_service.hpp
    include/cppcoro/config.hpp
    include/cppcoro/on_scope_exit.hpp
    include/cppcoro/file_share_mode.hpp
    include/cppcoro/file_open_mode.hpp
    include/cppcoro/file_buffering_mode.hpp
    include/cppcoro/file.hpp
    include/cppcoro/fmap.hpp
    include/cppcoro/when_all.hpp
    include/cppcoro/when_all_ready.hpp
    include/cppcoro/resume_on.hpp
    include/cppcoro/schedule_on.hpp
    include/cppcoro/generator.hpp
    include/cppcoro/readable_file.hpp
    include/cppcoro/recursive_generator.hpp
    include/cppcoro/writable_file.hpp
    include/cppcoro/read_only_file.hpp
    include/cppcoro/write_only_file.hpp
    include/cppcoro/read_write_file.hpp
    include/cppcoro/file_read_operation.hpp
    include/cppcoro/file_write_operation.hpp
    include/cppcoro/static_thread_pool.hpp
)

list(APPEND detail_headers
    include/cppcoro/detail/void_value.hpp
    include/cppcoro/detail/when_all_ready_awaitable.hpp
    include/cppcoro/detail/when_all_counter.hpp
    include/cppcoro/detail/when_all_task.hpp
    include/cppcoro/detail/get_awaiter.hpp
    include/cppcoro/detail/is_awaiter.hpp
    include/cppcoro/detail/any.hpp
    include/cppcoro/detail/sync_wait_task.hpp
    include/cppcoro/detail/unwrap_reference.hpp
    include/cppcoro/detail/lightweight_manual_reset_event.hpp
)

list(APPEND net_headers
    include/cppcoro/net/ip_address.hpp
    include/cppcoro/net/ip_endpoint.hpp
    include/cppcoro/net/ipv4_address.hpp
    include/cppcoro/net/ipv4_endpoint.hpp
    include/cppcoro/net/ipv6_address.hpp
    include/cppcoro/net/ipv6_endpoint.hpp
    include/cppcoro/net/socket.hpp
)

target_include_directories(cppcoro
PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include>
)

if(${CMAKE_CXX_COMPILER_ID} MATCHES Clang)
    if(WIN32)
        target_compile_options(cppcoro
        PUBLIC
            /std:c++latest
            -fms-compatibility -Xclang -fcoroutines-ts
        )
        target_compile_definitions(cppcoro
        PUBLIC
            _RESUMABLE_FUNCTIONS_SUPPORTED
        )

    else()
        target_compile_options(cppcoro
        PUBLIC
            -std=c++1z -fcoroutines-ts
            -stdlib=libc++
        PRIVATE
            -fPIC
        )
        target_link_libraries(cppcoro
        PUBLIC
            c++ pthread
        PRIVATE
            -Wall
        )
    endif()

elseif(MSVC)
    target_compile_options(cppcoro
    PUBLIC
        /std:c++latest /await
        /W4
    PRIVATE
        "/analyze:max_paths 512"
    )
    if(CMAKE_GENERATOR_PLATFORM STREQUAL x64)
        target_compile_options(cppcoro
        PUBLIC
            /await:heapelide
        )
    endif()

endif()

if(WIN32)
    set_target_properties(cppcoro
    PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS True
    )

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

install(FILES       ${headers}
        DESTINATION ${CMAKE_INSTALL_PREFIX}/include/cppcoro
)
install(FILES       ${detail_headers}
        DESTINATION ${CMAKE_INSTALL_PREFIX}/include/cppcoro/details
)
install(FILES       ${net_headers}
        DESTINATION ${CMAKE_INSTALL_PREFIX}/include/cppcoro/net
)
install(TARGETS     cppcoro
        EXPORT      ${PROJECT_NAME}-config
        RUNTIME     DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
        LIBRARY     DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        ARCHIVE     DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)

install(EXPORT      ${PROJECT_NAME}-config
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/${PROJECT_NAME}
)

include(CMakePackageConfigHelpers)
set(VERSION_FILE_PATH   ${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}-config-version.cmake)
write_basic_package_version_file(${VERSION_FILE_PATH}
    VERSION             ${PROJECT_VERSION}
    COMPATIBILITY       SameMajorVersion
)

install(FILES           ${VERSION_FILE_PATH} 
        DESTINATION     ${CMAKE_INSTALL_PREFIX}/share/${PROJECT_NAME}
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

set_target_properties(cppcoro_test
PROPERTIES
    CXX_STANDARD 17 # follow that of `cppcoro` target
)

target_link_libraries(cppcoro_test
PRIVATE
    cppcoro
    Threads::Threads
)

set(conan_path ${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
if(EXISTS ${conan_path})
    include(${conan_path})
    conan_basic_setup()
    message(STATUS "using conan: ${conan_path}")

    target_include_directories(cppcoro_test
    PRIVATE
        ${CONAN_INCLUDE_DIRS}
    )
    target_compile_options(cppcoro_test
    PRIVATE
        ${CONAN_DEFINES}
    )
    #
    #   'doctest' is header-only library. 
    #   we don't need these functions (and it requires CMake 3.13+)
    #
    # target_link_directories(cppcoro_test 
    # PRIVATE
    #     ${CONAN_LIB_DIRS}
    # )
    target_link_libraries(cppcoro_test
    PRIVATE
        ${CONAN_LIBS}
    )
else()
    find_package(doctest CONFIG REQUIRED)
    get_target_property(DOCTEST_INCLUDE_DIR doctest::doctest
        INTERFACE_INCLUDE_DIRECTORIES
    )
    message(STATUS "using doctest: ${DOCTEST_INCLUDE_DIR}")
    target_link_libraries(cppcoro_test
    PRIVATE
        doctest::doctest
    )
endif()

if(WIN32)
    target_sources(cppcoro_test
    PRIVATE
        test/scheduling_operator_tests.cpp
        test/io_service_tests.cpp
        test/file_tests.cpp
        test/socket_tests.cpp
    )
else()

endif()

add_test(NAME test_all COMMAND cppcoro_test --duration=true )