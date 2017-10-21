# CMakeLists.txt testProgs directory

# headers
SET(COMMON_HDRS
playCommon.hh
)

# source files for MediaPreEncoderServer
SET(OPEN_RTSP_SRCS 
openRTSP.cpp
playCommon.cpp
)

SET(PLAY_SIP_SRCS 
playCommon.cpp
playSIP.cpp
)

SET(TEST_AMR_AUDIO_STREAMER_SRCS 
testAMRAudioStreamer.cpp
)

SET(TEST_H264_VIDEO_STREAMER_SRCS 
testH264VideoStreamer.cpp
)

SET(TEST_H265_VIDEO_STREAMER_SRCS 
testH265VideoStreamer.cpp
)

SET(ON_DEMAND_RTSP_SERVER_SRCS 
testOnDemandRTSPServer.cpp
)

SET(TEST_RTSP_CLIENT_SRCS 
testRTSPClient.cpp
)

ADD_EXECUTABLE(openRTSP ${COMMON_HDRS} ${OPEN_RTSP_SRCS})
TARGET_LINK_LIBRARIES(
openRTSP
BasicUsageEnvironment
groupsock
liveMedia
UsageEnvironment
ws2_32
winmm
) 

ADD_EXECUTABLE(playSip ${COMMON_HDRS} ${PLAY_SIP_SRCS})
TARGET_LINK_LIBRARIES(
playSip
BasicUsageEnvironment
groupsock
liveMedia
UsageEnvironment
ws2_32
winmm
) 

ADD_EXECUTABLE(testAmrAudioStreamer ${COMMON_HDRS} ${TEST_AMR_AUDIO_STREAMER_SRCS})
TARGET_LINK_LIBRARIES(
testAmrAudioStreamer
BasicUsageEnvironment
groupsock
liveMedia
UsageEnvironment
ws2_32
winmm
) 

ADD_EXECUTABLE(testH264VideoStreamer ${COMMON_HDRS} ${TEST_H264_VIDEO_STREAMER_SRCS})
TARGET_LINK_LIBRARIES(
testH264VideoStreamer
BasicUsageEnvironment
groupsock
liveMedia
UsageEnvironment
ws2_32
winmm
) 

ADD_EXECUTABLE(testH265VideoStreamer ${COMMON_HDRS} ${TEST_H265_VIDEO_STREAMER_SRCS})
TARGET_LINK_LIBRARIES(
testH265VideoStreamer
BasicUsageEnvironment
groupsock
liveMedia
UsageEnvironment
ws2_32
winmm
) 

ADD_EXECUTABLE(testOnDemandRTSPServer ${COMMON_HDRS} ${ON_DEMAND_RTSP_SERVER_SRCS})
TARGET_LINK_LIBRARIES(
testOnDemandRTSPServer
BasicUsageEnvironment
groupsock
liveMedia
UsageEnvironment
ws2_32
winmm
) 

ADD_EXECUTABLE(testRTSPClient ${COMMON_HDRS} ${TEST_RTSP_CLIENT_SRCS})
TARGET_LINK_LIBRARIES(
testRTSPClient
BasicUsageEnvironment
groupsock
liveMedia
UsageEnvironment
ws2_32
winmm
) 
