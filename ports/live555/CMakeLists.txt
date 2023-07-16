cmake_minimum_required(VERSION 3.5)
project(live555 C CXX)

set(CMAKE_CXX_STANDARD 20)
include_directories(
    BasicUsageEnvironment/include
    groupsock/include
    liveMedia/include
    UsageEnvironment/include
)

if (WIN32)
    add_definitions(-DNO_GETIFADDRS)
endif(WIN32)

if (NOT MSVC)
    add_compile_options(-DSOCKLEN_T=socklen_t)
endif()

file(GLOB BASIC_USAGE_ENVIRONMENT_SRCS BasicUsageEnvironment/*.c BasicUsageEnvironment/*.cpp)
add_library(BasicUsageEnvironment ${BASIC_USAGE_ENVIRONMENT_SRCS})

file(GLOB GROUPSOCK_SRCS groupsock/*.c groupsock/*.cpp)
add_library(groupsock ${GROUPSOCK_SRCS})

file(GLOB LIVEMEDIA_SRCS liveMedia/*.c liveMedia/*.cpp)
add_library(liveMedia ${LIVEMEDIA_SRCS})
find_package(OpenSSL REQUIRED)
target_include_directories(liveMedia PRIVATE "${OPENSSL_INCLUDE_DIR}")

file(GLOB USAGE_ENVIRONMENT_SRCS UsageEnvironment/*.c UsageEnvironment/*.cpp)
add_library(UsageEnvironment ${USAGE_ENVIRONMENT_SRCS})

file(WRITE "${CMAKE_BINARY_DIR}/unofficial-live555-config.cmake"
[[
include(CMakeFindDependencyMacro)

find_dependency(OpenSSL)

include("${CMAKE_CURRENT_LIST_DIR}/unofficial-live555-targets.cmake")
]]
)

install(FILES "${CMAKE_BINARY_DIR}/unofficial-live555-config.cmake" DESTINATION share/unofficial-live555)

install(TARGETS groupsock BasicUsageEnvironment liveMedia UsageEnvironment
    EXPORT unofficial-live555-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT unofficial-live555-targets
    FILE unofficial-live555-targets.cmake
    NAMESPACE unofficial::
    DESTINATION share/unofficial-live555
)
