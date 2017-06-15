# CMakeLists.txt in groupsock

SET(GROUPSOCK_SRCS
GroupEId.cpp
Groupsock.cpp
GroupsockHelper.cpp
inet.c
IOHandlers.cpp
NetAddress.cpp
NetInterface.cpp
)

SET(GROUPSOCK_HEADERS
include/GroupEId.hh
include/Groupsock.hh
include/GroupsockHelper.hh
include/groupsock_version.hh
include/IOHandlers.hh
include/NetAddress.hh
include/NetInterface.hh
include/TunnelEncaps.hh
)

INCLUDE_DIRECTORIES(
${live555Includes}
)

ADD_LIBRARY( groupsock STATIC ${GROUPSOCK_HEADERS} ${GROUPSOCK_SRCS})
