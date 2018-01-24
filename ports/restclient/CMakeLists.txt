cmake_minimum_required (VERSION 3.9)
project (restclient)

find_package(CURL REQUIRED)

set (HEADERS
    include/restclient-cpp/connection.h
    include/restclient-cpp/helpers.h
    include/restclient-cpp/restclient.h
    include/restclient-cpp/version.h
)

set (SRCS
    source/connection.cc
    source/helpers.cc
    source/restclient.cc
)

include_directories(include ${CURL_INCLUDE_DIRS})
add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS -DHAVE_CONFIG_H)
add_library(restclient ${SRCS})

target_link_libraries(restclient PRIVATE ${CURL_LIBRARIES})

install(
  TARGETS restclient
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(FILES ${HEADERS} DESTINATION include/restclient-cpp)
