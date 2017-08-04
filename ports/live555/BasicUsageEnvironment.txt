# CMakeLists.txt in BasicUsageEnvironment

SET(BASIC_USAGE_ENVIRONMENT_SRCS 
BasicHashTable.cpp
BasicTaskScheduler.cpp
BasicTaskScheduler0.cpp
BasicUsageEnvironment.cpp
BasicUsageEnvironment0.cpp
DelayQueue.cpp
)

SET(BASIC_USAGE_ENVIRONMENT_HEADERS
include/BasicHashTable.hh
include/BasicUsageEnvironment.hh
include/BasicUsageEnvironment0.hh
include/BasicUsageEnvironment_version.hh
include/DelayQueue.hh
include/HandlerSet.hh
)

INCLUDE_DIRECTORIES(
${live555Includes}
)

ADD_LIBRARY( BasicUsageEnvironment STATIC ${BASIC_USAGE_ENVIRONMENT_HEADERS} ${BASIC_USAGE_ENVIRONMENT_SRCS})
