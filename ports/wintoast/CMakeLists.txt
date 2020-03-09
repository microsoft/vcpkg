cmake_minimum_required(VERSION 3.11)
project(wintoast)

set(SRC_FILES
src/wintoastlib.cpp
)

add_library(wintoast ${SRC_FILES})

target_include_directories(wintoast PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include/wintoast>
)

# Install targets
install(TARGETS wintoast
	RUNTIME DESTINATION bin 
	LIBRARY DESTINATION lib 
	ARCHIVE DESTINATION lib 
)

# Install headers
if (INSTALL_HEADERS)
  install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/wintoastlib.h DESTINATION include/wintoast)
endif()