cmake_minimum_required(VERSION 3.13)
project(quickfast CXX)

set(CMAKE_CXX_STANDARD 11) # Boost v1.84.0 libraries require C++11

option(BUILD_SHARED_LIBS "Build shared instead of static library" ON)

find_package(Boost REQUIRED COMPONENTS thread)
find_package(XercesC REQUIRED)

file(GLOB SOURCES 
	quickfast/Application/*.cpp
	quickfast/Common/*.cpp
	quickfast/Codecs/*.cpp
	quickfast/Communication/*.cpp
	quickfast/Messages/*.cpp
)

file(GLOB HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
	quickfast/Application/*.h
	quickfast/Common/*.h
	quickfast/Codecs/*.h
	quickfast/Communication/*.h
	quickfast/Messages/*.h
)

if(BUILD_SHARED_LIBS)
	add_library(quickfast SHARED ${HEADERS} ${SOURCES})
	target_compile_definitions(quickfast PRIVATE -DQUICKFAST_BUILD_DLL)
else()
	add_library(quickfast STATIC ${HEADERS} ${SOURCES})
	target_compile_definitions(quickfast PUBLIC -DQUICKFAST_HAS_DLL=0)
endif()

target_include_directories(quickfast PUBLIC
	$<INSTALL_INTERFACE:include>
	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
	$<BUILD_INTERFACE:${Boost_INCLUDE_DIRS}>
)

target_link_libraries(quickfast PRIVATE
	${Boost_LIBRARIES} 
	XercesC::XercesC
)

install(TARGETS quickfast EXPORT quickfast-config 
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(EXPORT quickfast-config DESTINATION share/cmake/quickfast)

foreach (HEADER ${HEADERS} )
    get_filename_component(HEADER_DIR ${HEADER} DIRECTORY)
    install(FILES ${HEADER} DESTINATION include/${HEADER_DIR})
endforeach()
