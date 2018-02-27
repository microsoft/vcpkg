cmake_minimum_required(VERSION 3.5)
project(live555 CXX)

include_directories(
    BasicUsageEnvironment/include
    groupsock/include
    liveMedia/include
    UsageEnvironment/include
)

file(GLOB BASIC_USAGE_ENVIRONMENT_SRCS BasicUsageEnvironment/*.cpp)
add_library(BasicUsageEnvironment ${BASIC_USAGE_ENVIRONMENT_SRCS})

file(GLOB GROUPSOCK_SRCS groupsock/*.cpp)
add_library(groupsock ${GROUPSOCK_SRCS})

file(GLOB LIVEMEDIA_SRCS liveMedia/*.cpp)
add_library(liveMedia ${LIVEMEDIA_SRCS})

file(GLOB USAGE_ENVIRONMENT_SRCS UsageEnvironment/*.cpp)
add_library(UsageEnvironment ${LIVEMEDIA_SRCS})

install(TARGETS groupsock BasicUsageEnvironment liveMedia UsageEnvironment
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
