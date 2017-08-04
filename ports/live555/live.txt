# CMakeLists.txt in live

# includes
INCLUDE_DIRECTORIES(
${live555Includes}
)

ADD_SUBDIRECTORY(BasicUsageEnvironment)
ADD_SUBDIRECTORY(groupsock)
ADD_SUBDIRECTORY(liveMedia)
#ADD_SUBDIRECTORY(mediaServer)
#ADD_SUBDIRECTORY(proxyServer)
ADD_SUBDIRECTORY(UsageEnvironment)
#ADD_SUBDIRECTORY(testProgs)
