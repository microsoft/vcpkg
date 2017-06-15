# CMakeLists.txt mediaServer directory

# headers
SET(MEDIA_SERVER_HDRS
DynamicRTSPServer.hh
)

# source files for mediaServer
SET(MEDIA_SERVER_SRCS 
DynamicRTSPServer.cpp
live555MediaServer.cpp
)

ADD_EXECUTABLE(mediaServer ${MEDIA_SERVER_HDRS} ${MEDIA_SERVER_SRCS})
TARGET_LINK_LIBRARIES(
mediaServer
BasicUsageEnvironment
groupsock
liveMedia
UsageEnvironment
ws2_32
winmm
) 
