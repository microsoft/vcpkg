# CMakeLists.txt in UsageEnvironment

SET(USAGE_ENVIRONMENT_SRCS
HashTable.cpp
strDup.cpp
UsageEnvironment.cpp
)

SET(USAGE_ENVIRONMENT_HEADERS
include/Boolean.hh
include/HashTable.hh
include/strDup.hh
include/UsageEnvironment.hh
include/UsageEnvironment_version.hh
)

INCLUDE_DIRECTORIES(
${live555Includes}
)

ADD_LIBRARY( UsageEnvironment STATIC ${USAGE_ENVIRONMENT_HEADERS} ${USAGE_ENVIRONMENT_SRCS})
