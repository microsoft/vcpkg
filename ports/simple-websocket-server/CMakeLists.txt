cmake_minimum_required (VERSION 3.0)

project (Simple-WebSocket-Server)

option(USE_STANDALONE_ASIO "set ON to use standalone Asio instead of Boost.Asio" OFF)
option(BUILD_TESTING "set ON to build library tests" OFF)

if(NOT MSVC)
    add_compile_options(-std=c++11 -Wall -Wextra -Wsign-conversion)
    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        add_compile_options(-Wthread-safety)
    endif()
else()
    add_compile_options(/W1)
endif()

add_library(simple-websocket-server INTERFACE)

target_include_directories(simple-websocket-server INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})

find_package(Threads REQUIRED)
target_link_libraries(simple-websocket-server INTERFACE ${CMAKE_THREAD_LIBS_INIT})

# TODO 2020 when Debian Jessie LTS ends:
# Remove Boost system, thread, regex components; use Boost::<component> aliases; remove Boost target_include_directories
if(USE_STANDALONE_ASIO)
    target_compile_definitions(simple-websocket-server INTERFACE USE_STANDALONE_ASIO)
    find_path(ASIO_PATH asio.hpp)
    if(NOT ASIO_PATH)
        message(FATAL_ERROR "Standalone Asio not found")
    else()
        target_include_directories(simple-websocket-server INTERFACE ${ASIO_PATH})
    endif()
else()
    find_package(Boost 1.54.0 COMPONENTS system thread coroutine context REQUIRED)
    target_link_libraries(simple-websocket-server INTERFACE ${Boost_LIBRARIES})
    target_include_directories(simple-websocket-server INTERFACE ${Boost_INCLUDE_DIR})
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
        target_compile_definitions(simple-websocket-server INTERFACE USE_BOOST_REGEX)
        find_package(Boost 1.54.0 COMPONENTS regex REQUIRED)
        target_link_libraries(simple-websocket-server INTERFACE ${Boost_LIBRARIES})
        target_include_directories(simple-websocket-server INTERFACE ${Boost_INCLUDE_DIR})
    endif()
endif()
if(WIN32)
    target_link_libraries(simple-websocket-server INTERFACE ws2_32 wsock32)
endif()

if(APPLE)
    set(OPENSSL_ROOT_DIR "/usr/local/opt/openssl")
endif()
find_package(OpenSSL REQUIRED)
target_link_libraries(simple-websocket-server INTERFACE ${OPENSSL_LIBRARIES})
target_include_directories(simple-websocket-server INTERFACE ${OPENSSL_INCLUDE_DIR})

# If Simple-WebSocket-Server is not a sub-project:
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
#    add_executable(ws_examples ws_examples.cpp)
#    target_link_libraries(ws_examples simple-websocket-server)
#    if(OPENSSL_FOUND)
#        add_executable(wss_examples wss_examples.cpp)
#        target_link_libraries(wss_examples simple-websocket-server)
#    endif()
    
#    set(BUILD_TESTING ON)
    
    install(FILES asio_compatibility.hpp server_ws.hpp client_ws.hpp server_wss.hpp client_wss.hpp crypto.hpp utility.hpp status_code.hpp mutex.hpp DESTINATION include/simple-websocket-server)
endif()

if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
