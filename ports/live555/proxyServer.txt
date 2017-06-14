# CMakeLists.txt proxyServer directory

# source files for proxyServer
SET(PROXY_SERVER_SRCS 
live555ProxyServer.cpp
)

ADD_EXECUTABLE(proxyServer ${PROXY_SERVER_SRCS})
TARGET_LINK_LIBRARIES(
proxyServer
BasicUsageEnvironment
groupsock
liveMedia
UsageEnvironment
ws2_32
winmm
) 
