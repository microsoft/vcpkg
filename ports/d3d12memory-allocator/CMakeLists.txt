cmake_minimum_required(VERSION 3.11)

project(d3d12memory-allocator CXX)

add_library(${PROJECT_NAME}
	src/D3D12MemAlloc.h
	src/D3D12MemAlloc.cpp
)

target_include_directories(${PROJECT_NAME}
                           PUBLIC
                           $<INSTALL_INTERFACE:include>
)

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Export
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
	EXPORT ${PROJECT_NAME}Export 
	FILE ${PROJECT_NAME}Config.cmake 
	NAMESPACE ${PROJECT_NAME}:: 
	DESTINATION share/${PROJECT_NAME}
)

if(NOT DISABLE_INSTALL_HEADER)
	install(
			FILES src/D3D12MemAlloc.h
			DESTINATION include
	)
endif()
