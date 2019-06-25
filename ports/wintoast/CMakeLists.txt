cmake_minimum_required(VERSION 3.11)
project(wintoast)

set(HEADER_FILES
src/wintoastlib.h
)

set(SRC_FILES
src/wintoastlib.cpp
)

add_library(wintoast ${SRC_FILES} ${HEADER_FILES})

install(TARGETS wintoast
	RUNTIME DESTINATION bin 
	LIBRARY DESTINATION lib 
	ARCHIVE DESTINATION lib 
)

install(FILES ${HEADER_FILES}  DESTINATION include/wintoast)
