cmake_minimum_required(VERSION 3.20)
project(b64)

if (BUILD_SHARED_LIBS)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/b64_dynamic_config.h ${CMAKE_CURRENT_BINARY_DIR}/b64_config.h)
else()
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/b64_static_config.h ${CMAKE_CURRENT_BINARY_DIR}/b64_config.h)
endif()

set(SRC_DIR src)
set(INC_DIR include/b64)
set(SOURCE_FILES ${SRC_DIR}/cdecode.c ${SRC_DIR}/cencode.c)
set(HEADER_FILES ${INC_DIR}/cdecode.h ${INC_DIR}/cencode.h ${INC_DIR}/decode.h ${INC_DIR}/encode.h ${INC_DIR}/ccommon.h ${CMAKE_CURRENT_BINARY_DIR}/b64_config.h)

add_library(b64 ${SOURCE_FILES} ${HEADER_FILES})

if (BUILD_SHARED_LIBS)
    target_compile_definitions(b64 PRIVATE LIBB64_EXPORTS=1)
endif()

target_include_directories(b64 PRIVATE include ${CMAKE_CURRENT_BINARY_DIR})

set_property(TARGET b64 
            PROPERTY PUBLIC_HEADER ${HEADER_FILES})

install(TARGETS b64
	EXPORT b64-targets
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include/b64
)

install(EXPORT b64-targets 
	FILE b64-targets.cmake
	DESTINATION lib/cmake/b64)

