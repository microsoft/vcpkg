cmake_minimum_required(VERSION 3.1 FATAL_ERROR)
project(plustache LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Boost REQUIRED COMPONENTS regex)

add_library(
	plustache
	
     src/template.cpp
	 src/context.cpp
	)
	
	
target_include_directories(
	plustache
	
	PUBLIC
	  ${CMAKE_CURRENT_LIST_DIR}/include
	PRIVATE 
	  ${Boost_INCLUDE_DIRS}
)

target_link_libraries(
	plustache
	
	PRIVATE
	  ${Boost_LIBRARIES}
)


install(TARGETS plustache
        RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
       )
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/include/plustache DESTINATION include)
