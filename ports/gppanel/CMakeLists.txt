cmake_minimum_required(VERSION 3.13)
project(gpPanel CXX)

set(wxWidgets_EXCLUDE_COMMON_LIBRARIES TRUE)
find_package(wxWidgets REQUIRED COMPONENTS core base)
include(${wxWidgets_USE_FILE})

file(GLOB_RECURSE SOURCES "gpPanel/*.cpp")
file(GLOB HEADERS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/include" "include/*.h")

add_library(gpPanel STATIC ${SOURCES})
target_compile_definitions(gpPanel PRIVATE _CRT_SECURE_NO_WARNINGS)

target_include_directories(gpPanel PUBLIC
	$<INSTALL_INTERFACE:include>
	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
)

target_link_libraries(gpPanel PRIVATE ${wxWidgets_LIBRARIES})

install(TARGETS gpPanel EXPORT gpPanel-config 
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(EXPORT gpPanel-config DESTINATION share/cmake/gpPanel)

foreach(HEADER ${HEADERS})
    get_filename_component(HEADER_DIR ${HEADER} DIRECTORY)
    install(FILES include/${HEADER} DESTINATION include/gpPanel/${HEADER_DIR})
endforeach()
