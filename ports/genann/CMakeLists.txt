cmake_minimum_required(VERSION 3.11)
project(genann)

set(SRC_FILES
genann.c
)

add_library(genann ${SRC_FILES})

target_include_directories(genann PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include/genann>
)

# Install targets
install(TARGETS genann
	RUNTIME DESTINATION bin 
	LIBRARY DESTINATION lib 
	ARCHIVE DESTINATION lib 
)

# Install headers
if (INSTALL_HEADERS)
  install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/genann.h DESTINATION include/genann)
endif() 